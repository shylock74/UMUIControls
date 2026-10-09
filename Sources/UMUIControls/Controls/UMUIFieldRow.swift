//
//  UMUIFieldRow.swift
//  UMUIControls
//
//  A label on one line and a control that takes the rest of the row. Rows with the same
//  `labelWidth` line their controls up.
//

import SwiftUI

/// A row of an inspector: label, then the control.
///
/// The label is on one line. If it is longer than `labelWidth` the column widens instead
/// of truncating it.
///
/// Usage:
/// ```swift
/// UMUIFieldRow("Blur", labelWidth: 72) {
///     UMUIScrubField(value: $blur, range: 0...100, step: 1, unit: "px")
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIFieldRow<Content: View>: View {

    public let label: String
    public let labelWidth: CGFloat
    public let content: Content

    public init(
        _ label: String,
        labelWidth: CGFloat = 72,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.labelWidth = labelWidth
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .umLabelColumn(labelWidth)
            content
        }
    }
}
