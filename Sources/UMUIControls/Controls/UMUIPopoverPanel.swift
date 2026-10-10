//
//  UMUIPopoverPanel.swift
//  UMUIControls
//
//  Standard content container for popovers: a headline title, an optional help
//  line and the content. It has no confirm button: popovers apply changes live
//  and close with Esc or a click outside. Use `onClose` to commit buffered edits.
//

import SwiftUI

@available(macOS 11.0, *)
public struct UMUIPopoverPanel<Content: View>: View {

    @Environment(\.umuiTheme) private var theme

    private let title: String
    private let help: String?
    private let width: CGFloat?
    private let onClose: (() -> Void)?
    private let content: Content

    /// - Parameters:
    ///   - title: Headline shown at the top.
    ///   - help: Optional one-line explanation under the title.
    ///   - width: Fixed width; `nil` lets the content decide.
    ///   - onClose: Called when the popover disappears (commit buffered edits here).
    ///   - content: The popover body.
    public init(
        _ title: String,
        help: String? = nil,
        width: CGFloat? = nil,
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.help = help
        self.width = width
        self.onClose = onClose
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.space3) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.headlineFont)
                    .foregroundColor(theme.textPrimary)
                if let help {
                    Text(help)
                        .font(theme.footnoteFont)
                        .foregroundColor(theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            content
        }
        .padding(theme.space4)
        .frame(width: width, alignment: .leading)
        .onDisappear { onClose?() }
    }
}
