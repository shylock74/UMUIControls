//
//  UMUINumberControl.swift
//  UMUIControls
//
//  A compact number control combining a label, slider, text field, and unit indicator.
//  Supports percentage mode, custom decimal precision, and custom units.
//

import SwiftUI

/// Sizing modes for UMUINumberControl.
@available(macOS 11.0, *)
public enum UMUINumberControlSize: Sendable, Equatable {
    case normal
    case small
}

/// A compact horizontal control for editing a numeric value with a label, slider, text field, and optional unit.
///
/// Usage:
/// ```swift
/// UMUINumberControl(title: "Opacity", value: $opacity, range: 0...1, isPercentage: true, size: .normal)
/// ```
@available(macOS 11.0, *)
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
    
    /// The sizing mode of the number control.
    public let size: UMUINumberControlSize
    
    /// The width of the label area.
    public var labelWidth: CGFloat
    
    /// The width of the text field.
    public var fieldWidth: CGFloat
    
    /// The width of the unit text area.
    public var unitWidth: CGFloat
    
    /// Creates a new number control.
    /// - Parameters:
    ///   - title: The label text.
    ///   - value: Binding to the numeric value.
    ///   - range: The valid range for the slider.
    ///   - isPercentage: Whether to display/edit as percentage (value * 100).
    ///   - unit: Optional unit string.
    ///   - decimals: Number of decimal places (default 0).
    ///   - size: Sizing mode (default is `.normal`).
    ///   - labelWidth: Width of the label area (default 50).
    ///   - fieldWidth: Width of the text field (default 60).
    public init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        isPercentage: Bool = false,
        unit: String? = nil,
        decimals: Int = 0,
        size: UMUINumberControlSize = .small,
        labelWidth: CGFloat = 50,
        fieldWidth: CGFloat = 60,
        unitWidth: CGFloat = 16
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.isPercentage = isPercentage
        self.unit = unit
        self.decimals = decimals
        self.size = size
        self.labelWidth = labelWidth
        self.fieldWidth = fieldWidth
        self.unitWidth = unitWidth
    }
    
    /// Local text value representing the input field value to bypass SwiftUI formatter bugs.
    @State private var textValue: String = ""
    
    /// The computed unit string to display.
    private var computedUnit: String {
        if let unit = unit { return unit }
        return isPercentage ? "%" : ""
    }
    
    private var displayValue: Double {
        isPercentage ? value * 100 : value
    }
    
    private func formatNumber(_ val: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: val)) ?? ""
    }
    
    private func parseDouble(_ str: String) -> Double? {
        let cleaned = str.replacingOccurrences(of: ",", with: ".")
        if let doubleVal = Double(cleaned) {
            return doubleVal
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: str)?.doubleValue
    }
    
    private func updateValue(from parsed: Double) {
        let actualVal = isPercentage ? parsed / 100 : parsed
        // Clamp to range
        let clamped = min(max(actualVal, range.lowerBound), range.upperBound)
        value = clamped
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 4) {
            // Label
            HStack(spacing: 0) {
                Text(title)
                    .font(size == .normal ? .body : .caption)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .frame(width: labelWidth)
            
            // Slider
            Slider(value: $value, in: range)
                .labelsHidden()
                .controlSize(size == .normal ? .small : .mini)
            
            // Text Field
            TextField(
                "",
                text: $textValue,
                onEditingChanged: { isEditing in
                    if !isEditing {
                        if let parsed = parseDouble(textValue) {
                            updateValue(from: parsed)
                        }
                        textValue = formatNumber(displayValue)
                    }
                },
                onCommit: {
                    if let parsed = parseDouble(textValue) {
                        updateValue(from: parsed)
                    }
                    textValue = formatNumber(displayValue)
                }
            )
            .font(size == .normal ? .body : .caption)
            .textFieldStyle(.roundedBorder)
            .controlSize(size == .normal ? .small : .mini)
            .frame(width: fieldWidth)
            .multilineTextAlignment(.trailing)
            
            // Unit
            Text(computedUnit)
                .font(size == .normal ? .caption : .caption2)
                .foregroundColor(.secondary)
                .frame(width: unitWidth, alignment: .leading)
        }
        .onAppear {
            textValue = formatNumber(displayValue)
        }
        .onChange(of: value) { newValue in
            // Only update textValue if the parsed double from textValue is different from displayValue.
            // This prevents cursor jumping and infinite loops when typing.
            if let parsed = parseDouble(textValue) {
                let actualVal = isPercentage ? parsed / 100 : parsed
                if abs(actualVal - newValue) > 0.0001 {
                    textValue = formatNumber(displayValue)
                }
            } else {
                textValue = formatNumber(displayValue)
            }
        }
    }
}
