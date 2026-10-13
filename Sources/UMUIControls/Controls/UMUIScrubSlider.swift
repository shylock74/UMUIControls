//
//  UMUIScrubSlider.swift
//  UMUIControls
//
//  A thin slider followed by a scrub field, on one row. The slider writes to the bound
//  value when the drag ends; while dragging only the number moves, so the model (and
//  everything that depends on it) is not rewritten on every tick.
//

import SwiftUI

/// How the slider maps its position to the value.
@available(macOS 14.0, *)
public enum UMUIScrubSliderScale: Sendable {
    case linear
    /// Logarithmic: useful for ranges that span orders of magnitude (e.g. bitrate). The range must be > 0.
    case logarithmic
}

/// Slider + scrub field.
///
/// Usage:
/// ```swift
/// UMUIScrubSlider(value: $bitrate, range: 320...100000, step: 10, unit: "kbps", scale: .logarithmic)
/// UMUIScrubSlider(percent: $opacity)               // 0...1 shown as 0...100 %
/// ```
@available(macOS 14.0, *)
public struct UMUIScrubSlider: View {

    @Binding public var value: Double
    public let range: ClosedRange<Double>
    public let step: Double?
    public let decimals: Int
    public let unit: String?
    public let title: String?
    public let scale: UMUIScrubSliderScale
    public let maxSliderWidth: CGFloat
    public let fieldWidth: CGFloat
    /// Multiplier between the stored value and the number shown (100 for percentages).
    private let displayFactor: Double

    @State private var live: Double
    @State private var isDragging = false

    public init(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double? = nil,
        decimals: Int = 0,
        unit: String? = nil,
        title: String? = nil,
        scale: UMUIScrubSliderScale = .linear,
        maxSliderWidth: CGFloat = 200,
        fieldWidth: CGFloat = 64
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.decimals = decimals
        self.unit = unit
        self.title = title
        self.scale = scale
        self.maxSliderWidth = maxSliderWidth
        self.fieldWidth = fieldWidth
        self.displayFactor = 1
        self._live = State(initialValue: value.wrappedValue)
    }

    /// A fraction (usually 0...1) shown as a percentage.
    public init(
        percent value: Binding<Double>,
        range: ClosedRange<Double> = 0...1,
        step: Double = 0.01,
        title: String? = nil,
        maxSliderWidth: CGFloat = 200,
        fieldWidth: CGFloat = 64
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.decimals = 0
        self.unit = "%"
        self.title = title
        self.scale = .linear
        self.maxSliderWidth = maxSliderWidth
        self.fieldWidth = fieldWidth
        self.displayFactor = 100
        self._live = State(initialValue: value.wrappedValue)
    }

    // MARK: - Mapping

    private func snapped(_ v: Double) -> Double {
        var r = min(max(v, range.lowerBound), range.upperBound)
        if let step, step > 0 {
            r = (range.lowerBound + ((r - range.lowerBound) / step).rounded() * step)
            r = min(max(r, range.lowerBound), range.upperBound)
        }
        return r
    }

    private var position: Double {
        switch scale {
        case .linear:
            return live
        case .logarithmic:
            let lo = log(max(range.lowerBound, .leastNormalMagnitude))
            let hi = log(range.upperBound)
            let f = (log(max(live, range.lowerBound)) - lo) / (hi - lo)
            return f
        }
    }

    private var sliderRange: ClosedRange<Double> {
        scale == .linear ? range : 0...1
    }

    private func value(forPosition p: Double) -> Double {
        switch scale {
        case .linear:
            return p
        case .logarithmic:
            let lo = log(max(range.lowerBound, .leastNormalMagnitude))
            let hi = log(range.upperBound)
            return exp(lo + p * (hi - lo))
        }
    }

    private func commit() {
        let v = snapped(live)
        if v != value { value = v }
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 8) {
            UMUISlider(
                value: Binding(
                    get: { position },
                    set: { live = snapped(value(forPosition: $0)) }
                ),
                range: sliderRange,
                size: .small,
                thumbAlwaysVisible: true
            )
            .frame(maxWidth: maxSliderWidth)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isDragging = true }
                    .onEnded { _ in isDragging = false; commit() }
            )

            UMUIScrubField(
                value: Binding(
                    get: { live * displayFactor },
                    set: { live = snapped($0 / displayFactor); commit() }
                ),
                range: (range.lowerBound * displayFactor)...(range.upperBound * displayFactor),
                step: step.map { $0 * displayFactor },
                decimals: decimals,
                unit: unit,
                title: title
            )
            .frame(width: fieldWidth)
        }
        .onChange(of: value) { _, new in
            if !isDragging { live = new }
        }
    }
}
