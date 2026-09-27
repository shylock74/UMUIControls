//
//  UMUINumberField.swift
//  UMUIControls
//
//  A numeric entry field without a slider: optional leading label, the same
//  rounded-rect border and focus glow as UMUITextField, and a trailing unit.
//  For values with no natural slider range, such as a frame width in pixels.
//

import SwiftUI

/// Sizing modes for `UMUINumberField`.
@available(macOS 11.0, *)
public enum UMUINumberFieldSize: Sendable, Equatable {
    case normal
    case small
}

/// A numeric field that writes its binding only on commit.
///
/// Keystrokes edit a local copy of the text. `value` is written on
/// **Enter/Return**, on **blur** and on **disappear**, clamped to `range` and
/// rounded to `decimals`. Unparsable text reverts to the last committed value.
///
/// Usage:
/// ```swift
/// UMUINumberField(label: "Width", value: $width, range: 16...8192, unit: "px")
/// ```
@available(macOS 12.0, *)
public struct UMUINumberField: View {
    /// The optional label displayed at the leading edge.
    public let label: String?

    /// The bound value.
    @Binding public var value: Double

    /// The accepted range; committed values are clamped to it.
    public let range: ClosedRange<Double>

    /// Fraction digits shown and kept on commit.
    public let decimals: Int

    /// An optional unit shown after the field.
    public let unit: String?

    /// Sizing mode (.normal or .small).
    public let size: UMUINumberFieldSize

    /// Minimum width of the label column; a longer label widens it instead of being truncated.
    public let labelWidth: CGFloat

    /// Width of the bordered field.
    public let fieldWidth: CGFloat

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    /// Creates a numeric field bound to a `Double`.
    public init(
        label: String? = nil,
        value: Binding<Double>,
        range: ClosedRange<Double> = -Double.greatestFiniteMagnitude ... Double.greatestFiniteMagnitude,
        decimals: Int = 0,
        unit: String? = nil,
        size: UMUINumberFieldSize = .small,
        labelWidth: CGFloat = 80,
        fieldWidth: CGFloat = 64
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.decimals = decimals
        self.unit = unit
        self.size = size
        self.labelWidth = labelWidth
        self.fieldWidth = fieldWidth
        _text = State(initialValue: Self.format(value.wrappedValue, decimals: decimals))
    }

    /// Creates a numeric field bound to an `Int`.
    public init(
        label: String? = nil,
        value: Binding<Int>,
        // Not Int.min...Int.max: Double(Int.max) rounds above Int.max, and
        // converting a value clamped to it back to Int would trap.
        range: ClosedRange<Int> = -1_000_000_000 ... 1_000_000_000,
        unit: String? = nil,
        size: UMUINumberFieldSize = .small,
        labelWidth: CGFloat = 80,
        fieldWidth: CGFloat = 64
    ) {
        self.init(
            label: label,
            value: value.umDouble,
            range: Double(range.lowerBound) ... Double(range.upperBound),
            decimals: 0,
            unit: unit,
            size: size,
            labelWidth: labelWidth,
            fieldWidth: fieldWidth
        )
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(font)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
                .umLabelColumn(labelWidth)
            }

            TextField("", text: $text)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .font(font.monospacedDigit())
                .multilineTextAlignment(.trailing)
                .onSubmit { commit() }
                .padding(.horizontal, size == .small ? 8 : 10)
                .padding(.vertical, size == .small ? 4 : 6)
                .frame(width: fieldWidth)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isFocused ? Color.accentColor : Color.secondary.opacity(0.3),
                            lineWidth: isFocused ? 1.5 : 1.0
                        )
                        .shadow(color: isFocused ? Color.accentColor.opacity(0.25) : Color.clear, radius: isFocused ? 3 : 0)
                )
                .animation(.easeOut(duration: 0.12), value: isFocused)

            if let unit = unit, !unit.isEmpty {
                Text(unit)
                    .font(size == .normal ? .caption : .caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: value) { newValue in
            // Outside changes win, but never while the user is typing.
            if !isFocused {
                text = Self.format(newValue, decimals: decimals)
            }
        }
        .onChange(of: isFocused) { focused in
            if !focused {
                commit()
            }
        }
        .onDisappear {
            commit()
        }
    }

    private var font: Font {
        size == .normal ? .body : .caption
    }

    /// Parses, clamps and rounds the text, then writes the binding if it changed.
    private func commit() {
        guard let parsed = Self.parse(text) else {
            text = Self.format(value, decimals: decimals)
            return
        }
        let factor = pow(10, Double(decimals))
        let clamped = min(max(parsed, range.lowerBound), range.upperBound)
        let rounded = (clamped * factor).rounded() / factor
        if rounded != value {
            value = rounded
        }
        text = Self.format(rounded, decimals: decimals)
    }

    private static func format(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }

    /// Accepts both `,` and `.` as decimal separator.
    private static func parse(_ text: String) -> Double? {
        let cleaned = text
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        return Double(cleaned)
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct UMUINumberField_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var width = 1920
        @State private var fps = 29.97

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                UMUINumberField(label: "Width", value: $width, range: 16 ... 8192, unit: "px")
                UMUINumberField(label: "Frame Rate", value: $fps, range: 1 ... 240, decimals: 3, unit: "fps")
            }
            .padding(20)
            .frame(width: 320)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
