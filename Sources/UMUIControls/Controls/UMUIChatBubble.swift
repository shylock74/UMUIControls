//
//  UMUIChatBubble.swift
//  UMUIControls
//
//  A conversation bubble for turn-by-turn chat threads: outgoing messages sit on the
//  right in the accent color, incoming ones on the left in a neutral card, and system
//  notes are centered and muted.
//

import SwiftUI

/// Who a `UMUIChatBubble` belongs to, which decides alignment and colors.
@available(macOS 12.0, *)
public enum UMUIChatBubbleRole: Sendable, Equatable {
    /// The local user: right-aligned, accent background, contrasting text.
    case outgoing

    /// The other side (a person or a model): left-aligned, neutral card.
    case incoming

    /// A note about the conversation itself: centered, muted, no card.
    case system
}

/// A chat message bubble with optional header (author) and footer (timestamp) captions.
///
/// Text is selectable, so users can copy what a model wrote.
///
/// Usage:
/// ```swift
/// UMUIChatBubble("Who is the target audience?", role: .incoming, header: "Assistant")
/// UMUIChatBubble("Young professionals in Milan.", role: .outgoing, footer: "10:42")
/// ```
@available(macOS 12.0, *)
public struct UMUIChatBubble: View {
    /// The message text.
    public let text: String

    /// Alignment and color role.
    public let role: UMUIChatBubbleRole

    /// Optional caption above the bubble (e.g. the author).
    public let header: String?

    /// Optional caption below the bubble (e.g. the time).
    public let footer: String?

    /// Optional SF Symbol shown next to the header.
    public let systemImage: String?

    /// Maximum bubble width before the text wraps.
    public let maxBubbleWidth: CGFloat

    @Environment(\.self) private var environment

    public init(
        _ text: String,
        role: UMUIChatBubbleRole,
        header: String? = nil,
        footer: String? = nil,
        systemImage: String? = nil,
        maxBubbleWidth: CGFloat = 460
    ) {
        self.text = text
        self.role = role
        self.header = header
        self.footer = footer
        self.systemImage = systemImage
        self.maxBubbleWidth = maxBubbleWidth
    }

    public var body: some View {
        switch role {
        case .system:
            HStack(spacing: 6) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                }
                Text(text)
                    .textSelection(.enabled)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)

        case .incoming, .outgoing:
            HStack(alignment: .bottom, spacing: 0) {
                if role == .outgoing {
                    Spacer(minLength: 40)
                }

                VStack(alignment: role == .outgoing ? .trailing : .leading, spacing: 3) {
                    if header != nil || systemImage != nil {
                        HStack(spacing: 4) {
                            if let systemImage = systemImage {
                                Image(systemName: systemImage)
                            }
                            if let header = header {
                                Text(header)
                            }
                        }
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    }

                    Text(text)
                        .font(.body)
                        .foregroundColor(textColor)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(bubbleColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(role == .incoming ? Color.secondary.opacity(0.2) : Color.clear, lineWidth: 1)
                        )
                        .frame(maxWidth: maxBubbleWidth, alignment: role == .outgoing ? .trailing : .leading)

                    if let footer = footer {
                        Text(footer)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                if role == .incoming {
                    Spacer(minLength: 40)
                }
            }
        }
    }

    private var bubbleColor: Color {
        role == .outgoing ? Color.accentColor : Color(.controlBackgroundColor)
    }

    private var textColor: Color {
        role == .outgoing ? Color.accentColor.umContrastingTextColor(in: environment) : Color.primary
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct UMUIChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            UMUIChatBubble("Session started", role: .system, systemImage: "sparkles")
            UMUIChatBubble("Who is the primary audience for this launch?", role: .incoming, header: "Assistant", systemImage: "sparkle")
            UMUIChatBubble("Young professionals, 25–35, based in Milan.", role: .outgoing, footer: "10:42")
        }
        .padding(20)
        .frame(width: 480)
    }
}
#endif
