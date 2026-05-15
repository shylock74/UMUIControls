//
//  UMUINumberControl.swift
//  UMUIControls
//
//  A compact number control combining a label, slider, text field, and unit indicator.
//  Supports percentage mode, custom decimal precision, and custom units.
//

import SwiftUI

/// A compact horizontal control for editing a numeric value with a label, slider, text field, and optional unit.
///
/// Usage:
/// ```swift
/// UMUINumberControl(title: "Opacity", value: $opacity, range: 0...1, isPercentage: true)
/// UMUINumberControl(title: "Radius", value: $radius, range: 0...50, unit: "px", decimals: 1)
/// ```
public struct UMUINumberControl: View {
    /// The label displayed at the leading edge.
    public let title: String
    
    /// The underlying value to edit.
    @Binding public var value: Double
    
    /// The valid range for the slider and value.
    public let range: ClosedRange<Double>
    
    /// When `true`, the displayed value is multiplied by 100 (and the unit defaults to "%").
    public var isPercentage: Bool
    
    /// An optional unit string (e.g. "px", "s", "Mbps"). When `nil` and `isPercentage` is true, defaults to "%".
    public var unit: String?
    
    /// The number of decimal places shown in the text field.
    public var decimals: Int
    
    /// The width of the label area.
    public var labelWidth: CGFloat
    
    /// The width of the text field.
    public var fieldWidth: CGFloat
    
    /// Creates a new number control.
    /// - Parameters:
    ///   - title: The label text.
    ///   - value: Binding to the numeric value.
    ///   - range: The valid range for the slider.
    ///   - isPercentage: Whether to display/edit as percentage (value * 100).
    ///   - unit: Optional unit string.
    ///   - decimals: Number of decimal places (default 0).
    ///   - labelWidth: Width of the label area (default 50).
    ///   - fieldWidth: Width of the text field (default 60).
    public init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        isPercentage: Bool = false,
        unit: String? = nil,
        decimals: Int = 0,
        labelWidth: CGFloat = 50,
        fieldWidth: CGFloat = 60
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.isPercentage = isPercentage
        self.unit = unit
        self.decimals = decimals
        self.labelWidth = labelWidth
        self.fieldWidth = fieldWidth
    }
    
    /// Binding that converts between internal value and display value (for percentage mode).
    private var displayBinding: Binding<Double> {
        Binding(
            get: { isPercentage ? self.value * 100 : self.value },
            set: { self.value = isPercentage ? $0 / 100 : $0 }
        )
    }
    
    /// The computed unit string to display.
    private var computedUnit: String {
        if let unit = unit { return unit }
        return isPercentage ? "%" : ""
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 4) {
            // Label
            HStack(spacing: 0) {
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .frame(width: labelWidth)
            
            // Slider
            Slider(value: $value, in: range)
                .labelsHidden()
                .controlSize(.mini)
            
            // Text Field
            TextField("", value: displayBinding,
                      format: .number.precision(.fractionLength(decimals)))
                .font(.caption)
                .textFieldStyle(.roundedBorder)
                .controlSize(.mini)
                .frame(width: fieldWidth)
                .multilineTextAlignment(.trailing)
            
            // Unit
            UMUICaptionGrayText(computedUnit)
                .frame(width: 16, alignment: .leading)
        }
    }
}
