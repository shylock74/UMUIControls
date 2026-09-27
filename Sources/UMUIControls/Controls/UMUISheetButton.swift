//
//  UMUISheetButton.swift
//  UMUIControls
//
//  A button that presents its content in a sheet with a title bar and a
//  Close button, for settings that do not deserve room in the main layout.
//

import SwiftUI

/// The look of the button that opens a `UMUISheetButton` sheet.
@available(macOS 11.0, *)
public enum UMUISheetButtonKind: Sendable, Equatable {
    /// A compact `UMUIMiniButton`.
    case mini(UMUIMiniButtonStyle)
    /// A `UMUICapsuleButton`.
    case capsule(UMUICapsuleButtonStyle, UMUICapsuleButtonSize)
}

/// A button presenting `content` in a sheet.
///
/// The sheet has a header with the title and a close glyph, the content, and a
/// footer with an accent **Close** button (Esc and Return both close it).
///
/// Usage:
/// ```swift
/// UMUISheetButton("Settings", systemImage: "gearshape.fill", sheetTitle: "Audio Pre-Clusterize") {
///     ClustersSettingsView(settings: $settings)
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUISheetButton<SheetContent: View>: View {
    /// The button title.
    public let title: String

    /// Optional SF Symbol shown before the title.
    public let systemImage: String?

    /// The title of the sheet; defaults to the button title.
    public let sheetTitle: String

    /// The look of the button.
    public let kind: UMUISheetButtonKind

    /// Title of the footer button that dismisses the sheet.
    public let closeTitle: String

    /// Called when the sheet is dismissed.
    public let onClose: (() -> Void)?

    /// The sheet content.
    public let content: () -> SheetContent

    @State private var isPresented = false

    /// Creates a sheet button.
    public init(
        _ title: String,
        systemImage: String? = nil,
        sheetTitle: String? = nil,
        kind: UMUISheetButtonKind = .mini(.gray),
        closeTitle: String = "Close",
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent
    ) {
        self.title = title
        self.systemImage = systemImage
        self.sheetTitle = sheetTitle ?? title
        self.kind = kind
        self.closeTitle = closeTitle
        self.onClose = onClose
        self.content = content
    }

    public var body: some View {
        button
            .sheet(isPresented: $isPresented, onDismiss: onClose) {
                UMUISheetContainer(title: sheetTitle,
                                   closeTitle: closeTitle,
                                   isPresented: $isPresented,
                                   content: content)
            }
    }

    @ViewBuilder
    private var button: some View {
        switch kind {
        case .mini(let style):
            if let systemImage = systemImage {
                UMUIMiniButton(title, systemImage: systemImage, style: style) { isPresented = true }
            } else {
                UMUIMiniButton(title, style: style) { isPresented = true }
            }
        case .capsule(let style, let size):
            if let systemImage = systemImage {
                UMUICapsuleButton(title, systemImage: systemImage, style: style, size: size) { isPresented = true }
            } else {
                UMUICapsuleButton(title, style: style, size: size) { isPresented = true }
            }
        }
    }
}

// MARK: - Sheet container

/// The chrome of a `UMUISheetButton` sheet: header, content, footer.
///
/// Public so a sheet presented by other means can share the same look.
@available(macOS 11.0, *)
public struct UMUISheetContainer<Content: View>: View {
    /// The sheet title.
    public let title: String

    /// Title of the footer button that dismisses the sheet.
    public let closeTitle: String

    /// Presentation binding, set to `false` to dismiss.
    @Binding public var isPresented: Bool

    /// The sheet content.
    public let content: () -> Content

    /// Creates the sheet chrome around `content`.
    public init(
        title: String,
        closeTitle: String = "Close",
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.closeTitle = closeTitle
        self._isPresented = isPresented
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                Spacer(minLength: 8)
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help(closeTitle)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            content()
                .padding(14)

            Divider()

            HStack {
                Spacer(minLength: 0)
                UMUICapsuleButton(closeTitle, style: .accent, size: .small) {
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .onExitCommand {
            isPresented = false
        }
    }
}
