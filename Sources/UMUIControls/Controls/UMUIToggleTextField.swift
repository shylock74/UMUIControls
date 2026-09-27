//
//  UMUIToggleTextField.swift
//  UMUIControls
//
//  A switch that enables an optional piece of text: the field appears next to
//  the switch only while it is on (a file-name prefix, a custom suffix, ...).
//

import SwiftUI

/// A `UMUISmallSwitch` in the label column followed, while on, by a `UMUITextField`.
///
/// Usage:
/// ```swift
/// UMUIToggleTextField("Add Prefix", isOn: $prefix.enable, text: $prefix.string, placeholder: "Prefix")
/// ```
@available(macOS 11.0, *)
public struct UMUIToggleTextField: View {
    /// The switch label.
    public let title: String

    /// Whether the text is in use.
    @Binding public var isOn: Bool

    /// The optional text.
    @Binding public var text: String

    /// Placeholder of the text field.
    public let placeholder: String

    /// Minimum width of the switch column, so several rows line their fields up.
    public let labelWidth: CGFloat

    /// Width of the text field; `nil` lets it take the remaining space.
    public let fieldWidth: CGFloat?

    /// Creates a toggled text field.
    public init(
        _ title: String,
        isOn: Binding<Bool>,
        text: Binding<String>,
        placeholder: String = "",
        labelWidth: CGFloat = 80,
        fieldWidth: CGFloat? = nil
    ) {
        self.title = title
        self._isOn = isOn
        self._text = text
        self.placeholder = placeholder
        self.labelWidth = labelWidth
        self.fieldWidth = fieldWidth
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(spacing: 0) {
                UMUISmallSwitch(title, isOn: $isOn)
                Spacer(minLength: 0)
            }
            .umLabelColumn(labelWidth)

            if isOn {
                UMUITextField(placeholder: placeholder, value: $text)
                    .frame(width: fieldWidth)
                    .transition(.opacity)
            }

            Spacer(minLength: 0)
        }
        .animation(.easeInOut(duration: 0.15), value: isOn)
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIToggleTextField_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var prefixOn = true
        @State private var prefix = "Draft_"
        @State private var suffixOn = false
        @State private var suffix = ""

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                UMUIToggleTextField("Add Prefix", isOn: $prefixOn, text: $prefix, labelWidth: 100)
                UMUIToggleTextField("Add Suffix", isOn: $suffixOn, text: $suffix, labelWidth: 100)
            }
            .padding(20)
            .frame(width: 360)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
