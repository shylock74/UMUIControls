//
//  UMUILabeledRow.swift
//  UMUIControls
//
//  A leading label column followed by any control, laid out exactly like the
//  labels of the UMUIControls widgets, so a custom control lines up with them.
//

import SwiftUI

/// Sizing modes for `UMUILabeledRow`.
@available(macOS 11.0, *)
public enum UMUILabeledRowSize: Sendable, Equatable {
    case normal
    case small
}

/// Puts a leading label in the same column the UMUIControls widgets use, then
/// the content, then a trailing spacer.
///
/// Use it for a control that carries no label of its own (a searchable picker,
/// a drop area, a pair of fields) so it lines up with the rows around it.
///
/// Usage:
/// ```swift
/// UMUILabeledRow("Codec", labelWidth: 80) {
///     UMUISearchablePicker(items: codecs, selection: $codec)
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUILabeledRow<Content: View>: View {
    /// The label displayed at the leading edge.
    public let label: String

    /// Sizing mode (.normal or .small).
    public let size: UMUILabeledRowSize

    /// Minimum width of the label column; a longer label widens it instead of being truncated.
    public let labelWidth: CGFloat

    /// Vertical alignment between the label and the content.
    public let alignment: VerticalAlignment

    /// The control introduced by the label.
    public let content: Content

    /// Creates a labeled row.
    public init(
        _ label: String,
        size: UMUILabeledRowSize = .small,
        labelWidth: CGFloat = 80,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.size = size
        self.labelWidth = labelWidth
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: alignment, spacing: 8) {
            HStack(spacing: 0) {
                Text(label)
                    .font(size == .normal ? .body : .caption)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                Spacer(minLength: 0)
            }
            .umLabelColumn(labelWidth)

            content

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUILabeledRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 8) {
            UMUILabeledRow("Codec") {
                Text("ProRes 422")
                    .font(.caption)
            }
            UMUILabeledRow("A longer label") {
                Text("Widens its column")
                    .font(.caption)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}
#endif
