//
//  UMUIScrubField.swift
//  UMUIControls
//
//  A light numeric field for dense inspectors. At rest it is only a text: the editable
//  `TextField` exists while the user types. Drag sideways to change the value, click to type.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

/// A numeric field that is a text until it is edited.
///
/// - **Drag** horizontally on the value to change it. Shift is ×10, Option ÷10.
/// - **Click** to type. Return and a click elsewhere commit, Esc cancels, ↑ and ↓ step
///   the value (Shift ×10).
///
/// The binding is written at every step of a drag: the owner decides how often the
/// document sees it. Typed values are clamped to `range` and rounded to `decimals`.
///
/// Usage:
/// ```swift
/// UMUIScrubField(value: $blur, range: 0...100, step: 1, unit: "px")
/// ```
@available(macOS 14.0, *)
public struct UMUIScrubField: View {

    /// The bound value.
    @Binding public var value: Double

    /// The accepted range.
    public let range: ClosedRange<Double>

    /// The granularity of dragging and of the arrow keys. `nil` is continuous.
    public let step: Double?

    /// Fraction digits shown.
    public let decimals: Int

    /// A unit shown after the value, inside the field.
    public let unit: String?

    /// A short tag before the value ("X", "Y"), inside the field.
    public let prefix: String?

    /// How much the value changes for a point of dragging. `nil` is a thousandth of the range,
    /// and at least half a step.
    public let unitsPerPoint: Double?

    /// What the field is, for VoiceOver and the tooltip.
    public let title: String?

    /// The value stands for several things that don't agree: "---" is shown, and any value
    /// written (even the one in `value`) is a change.
    public let isMixed: Bool

    @State private var editing = false
    @State private var text = ""
    @State private var hovering = false
    @State private var dragStart: Double?
    @State private var dragAccumulated: Double = 0
    @State private var dragLastX: CGFloat = 0
    @FocusState private var focused: Bool

    public init(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double? = nil,
        decimals: Int = 0,
        unit: String? = nil,
        prefix: String? = nil,
        unitsPerPoint: Double? = nil,
        title: String? = nil,
        isMixed: Bool = false
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.decimals = decimals
        self.unit = unit
        self.prefix = prefix
        self.unitsPerPoint = unitsPerPoint
        self.title = title
        self.isMixed = isMixed
    }

    /// Creates a field bound to an `Int`.
    public init(
        value: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int = 1,
        unit: String? = nil,
        prefix: String? = nil,
        unitsPerPoint: Double? = nil,
        title: String? = nil,
        isMixed: Bool = false
    ) {
        self.init(
            value: Binding<Double>(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Int($0.rounded()) }
            ),
            range: Double(range.lowerBound) ... Double(range.upperBound),
            step: Double(step),
            decimals: 0,
            unit: unit,
            prefix: prefix,
            unitsPerPoint: unitsPerPoint,
            title: title,
            isMixed: isMixed
        )
    }

    public var body: some View {
        ZStack {
            if editing {
                editor
            } else {
                display
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 22)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.secondary.opacity(editing ? 0.08 : (hovering ? 0.22 : 0.14)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.accentColor, lineWidth: editing ? 1.5 : 0)
        )
        .onDisappear {
            if hovering {
                hovering = false
                #if os(macOS)
                NSCursor.pop()
                #endif
            }
        }
    }

    // MARK: At rest

    private var display: some View {
        HStack(spacing: 3) {
            if let prefix {
                Text(prefix)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Text(isMixed ? "---" : Self.format(value, decimals: decimals))
                .font(.caption)
                .monospacedDigit()
                .lineLimit(1)
            if let unit, !unit.isEmpty, !isMixed {
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onHover { inside in
            guard inside != hovering else { return }
            hovering = inside
            #if os(macOS)
            if inside {
                NSCursor.resizeLeftRight.push()
            } else {
                NSCursor.pop()
            }
            #endif
        }
        .gesture(drag)
        .onTapGesture { beginEditing() }
        .help(title.map { "\($0): drag to change, click to type" } ?? "Drag to change, click to type")
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title ?? "Value")
        .accessibilityValue(isMixed ? "Multiple values" : Self.format(value, decimals: decimals) + (unit.map { " " + $0 } ?? ""))
        .accessibilityAdjustableAction { direction in
            let delta = step ?? Self.unitStep(decimals: decimals)
            switch direction {
                case .increment:	write(value + delta)
                case .decrement:	write(value - delta)
                @unknown default:	break
            }
        }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 3)
            .onChanged { gesture in
                if dragStart == nil {
                    dragStart = value
                    dragAccumulated = 0
                    dragLastX = 0
                }
                // Accumulated, so that pressing Shift in the middle doesn't make the value jump
                let dx = gesture.translation.width - dragLastX
                dragLastX = gesture.translation.width
                dragAccumulated += Double(dx) * perPoint * Self.modifierMultiplier()
                write((dragStart ?? value) + dragAccumulated)
            }
            .onEnded { _ in
                dragStart = nil
            }
    }

    private var perPoint: Double {
        if let unitsPerPoint { return unitsPerPoint }
        let thousandth = (range.upperBound - range.lowerBound) / 1000
        return max(thousandth, (step ?? 0) / 2)
    }

    // MARK: Typing

    private var editor: some View {
        HStack(spacing: 3) {
            if let prefix {
                Text(prefix)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            TextField("", text: $text)
                .textFieldStyle(.plain)
                .font(.caption)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .focused($focused)
                .onSubmit { commit() }
                .onExitCommand { editing = false }
                .onKeyPress(.upArrow) { nudge(+1); return .handled }
                .onKeyPress(.downArrow) { nudge(-1); return .handled }
                .onChange(of: focused) { _, isFocused in
                    if !isFocused { commit() }
                }
            if let unit, !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 6)
    }

    private func beginEditing() {
        text = isMixed ? "" : Self.format(value, decimals: decimals)
        if hovering {
            hovering = false
            #if os(macOS)
            NSCursor.pop()
            #endif
        }
        editing = true
        DispatchQueue.main.async {
            focused = true
        }
    }

    private func commit() {
        guard editing else { return }
        editing = false
        guard let typed = Self.parse(text) else { return }
        write(typed, snapToStep: false)
    }

    private func nudge(_ direction: Double) {
        let delta = (step ?? Self.unitStep(decimals: decimals)) * Self.modifierMultiplier(shiftOnly: true)
        let base = Self.parse(text) ?? value
        let next = clamped(base + direction * delta)
        text = Self.format(next, decimals: decimals)
        write(next, snapToStep: false)
    }

    // MARK: Values

    private func clamped(_ v: Double) -> Double {
        min(max(v, range.lowerBound), range.upperBound)
    }

    /// Clamps, snaps and rounds the value, then writes it if it is a change.
    private func write(_ proposed: Double, snapToStep: Bool = true) {
        var v = proposed
        if snapToStep, let step, step > 0 {
            v = (v / step).rounded() * step
        }
        v = clamped(v)
        let factor = pow(10, Double(max(decimals, step.map { Self.fractionDigits(of: $0) } ?? 0)))
        v = (v * factor).rounded() / factor
        if v != value || isMixed {
            value = v
        }
    }

    private static func modifierMultiplier(shiftOnly: Bool = false) -> Double {
        #if os(macOS)
        let flags = NSEvent.modifierFlags
        if flags.contains(.shift) { return 10 }
        if !shiftOnly, flags.contains(.option) { return 0.1 }
        #endif
        return 1
    }

    private static func unitStep(decimals: Int) -> Double {
        pow(10, -Double(decimals))
    }

    private static func fractionDigits(of step: Double) -> Int {
        var digits = 0
        var scaled = step
        while digits < 6, abs(scaled - scaled.rounded()) > 1e-9 {
            scaled *= 10
            digits += 1
        }
        return digits
    }

    private static func format(_ v: Double, decimals: Int) -> String {
        // No "-0"
        let shown = abs(v) < 0.5 * unitStep(decimals: decimals) ? 0 : v
        return shown.formatted(.number.precision(.fractionLength(decimals)).grouping(.never))
    }

    /// Accepts both `,` and `.` as decimal separator.
    private static func parse(_ text: String) -> Double? {
        Double(text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: "."))
    }
}
