//
//  UMUIInspectorRow.swift
//  UMUIControls
//
//  A read-only label/value line for inspector panels (file size, resolution,
//  hashes, paths), with an optional trailing accessory and a Copy context menu.
//

import SwiftUI

/// A label/value row for inspectors.
///
/// Long values are truncated in the middle, so both ends of a path or hash stay
/// visible; the full value is in the tooltip and in the Copy context menu.
///
/// Usage:
/// ```swift
/// UMUIInspectorRow("Size", value: "1.2 MB")
/// UMUIInspectorRow("SHA-256", value: hash, isMonospaced: true) {
///     UMUIStatusPill("Verified", systemImage: "checkmark.seal.fill", style: .success)
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIInspectorRow<Accessory: View>: View {
    /// Leading label.
    public let label: String

    /// Displayed value.
    public let value: String

    /// Uses a monospaced font for the value (hashes, identifiers).
    public let isMonospaced: Bool

    /// Width reserved for the label.
    public let labelWidth: CGFloat

    /// Trailing accessory.
    public let accessory: Accessory

    public init(
        _ label: String,
        value: String,
        isMonospaced: Bool = false,
        labelWidth: CGFloat = 80,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.label = label
        self.value = value
        self.isMonospaced = isMonospaced
        self.labelWidth = labelWidth
        self.accessory = accessory()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .umLabelColumn(labelWidth)

            Text(value.isEmpty ? "—" : value)
                .font(isMonospaced ? .system(.caption, design: .monospaced) : .caption)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
                .help(value)
                .frame(maxWidth: .infinity, alignment: .leading)

            accessory
        }
        .contextMenu {
            Button("Copy") {
                #if os(macOS)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(value, forType: .string)
                #endif
            }
        }
    }
}

@available(macOS 11.0, *)
public extension UMUIInspectorRow where Accessory == EmptyView {
    /// Creates a row without accessory.
    init(
        _ label: String,
        value: String,
        isMonospaced: Bool = false,
        labelWidth: CGFloat = 80
    ) {
        self.init(label, value: value, isMonospaced: isMonospaced, labelWidth: labelWidth) {
            EmptyView()
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct UMUIInspectorRow_Previews: PreviewProvider {
    static var previews: some View {
        UMUISection("Asset") {
            UMUIInspectorRow("File", value: "slide_01_background.png")
            UMUIInspectorRow("Size", value: "1.2 MB")
            UMUIInspectorRow("Resolution", value: "1080 × 1350")
            UMUIInspectorRow("SHA-256", value: "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08", isMonospaced: true) {
                UMUIStatusPill("Verified", systemImage: "checkmark.seal.fill", style: .success)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}
#endif
