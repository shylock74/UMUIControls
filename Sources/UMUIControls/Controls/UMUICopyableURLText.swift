//
//  UMUICopyableURLText.swift
//  UMUIControls
//
//  A clickable URL / path text view that copies its string to the system pasteboard.
//  On hover, text turns white with a hand pointer. On click, it turns accent color and
//  displays a floating popover badge ("copied in the pasteboard") that stays for 1 second,
//  then smoothly fades out over 1 second.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

/// A text component displaying a URL or path that copies its target string to the clipboard on click.
///
/// Behavior:
/// - When `isEnabled` is true:
///   - Idle: displays in `baseColor` (defaults to `.secondary`).
///   - Hover: text turns `hoverColor` (defaults to `.white`) and shows a pointing hand cursor.
///   - Click: copies the URL to `NSPasteboard`, text transitions to `accentColor`, and a popover
///     badge with `popoverText` appears above the URL.
///   - The popover stays visible for 1 second, then smoothly fades out over 1 second back to the hover/base color.
/// - When `isEnabled` is false:
///   - Renders as a standard static `Text` view in `baseColor`.
@available(macOS 11.0, *)
public struct UMUICopyableURLText: View {
    /// The URL or text string to display and copy.
    public let url: String

    /// Optional alternative display string. If nil, `url` is displayed.
    public let displayText: String?

    /// Whether copy interaction and hover effects are enabled (e.g. true for remote URLs).
    public let isEnabled: Bool

    /// Font for the text.
    public let font: Font

    /// Popover message displayed upon copying.
    public let popoverText: String

    /// Idle color of the text when not hovered.
    public let baseColor: Color

    /// Color of the text when hovered.
    public let hoverColor: Color

    /// Custom accent color override for the clicked state and popover highlight.
    public let customAccentColor: Color?

    /// Line limit for the text (default 1).
    public let lineLimit: Int?

    /// Truncation mode for the text (default .middle).
    public let truncationMode: Text.TruncationMode

    /// Optional callback invoked whenever the text is copied.
    public let onCopy: ((String) -> Void)?

    @Environment(\.self) private var environment

    @State private var isHovered: Bool = false
    @State private var isCopied: Bool = false
    @State private var popoverOpacity: Double = 0.0
    @State private var dismissWorkItem: DispatchWorkItem? = nil

    public init(
        _ url: String,
        displayText: String? = nil,
        isEnabled: Bool = true,
        font: Font = .system(size: 11),
        popoverText: String = "copied in the pasteboard",
        baseColor: Color = .secondary,
        hoverColor: Color = .white,
        accentColor: Color? = nil,
        lineLimit: Int? = 1,
        truncationMode: Text.TruncationMode = .middle,
        onCopy: ((String) -> Void)? = nil
    ) {
        self.url = url
        self.displayText = displayText
        self.isEnabled = isEnabled
        self.font = font
        self.popoverText = popoverText
        self.baseColor = baseColor
        self.hoverColor = hoverColor
        self.customAccentColor = accentColor
        self.lineLimit = lineLimit
        self.truncationMode = truncationMode
        self.onCopy = onCopy
    }

    public var body: some View {
        if isEnabled {
            interactiveText
        } else {
            staticText
        }
    }

    private var textToDisplay: String {
        displayText ?? url
    }

    private var resolvedAccentColor: Color {
        customAccentColor ?? environment.umAccentColor ?? .accentColor
    }

    private var currentTextColor: Color {
        if isCopied {
            return resolvedAccentColor
        } else if isHovered {
            return hoverColor
        } else {
            return baseColor
        }
    }

    @ViewBuilder
    private var staticText: some View {
        Text(textToDisplay)
            .font(font)
            .foregroundColor(baseColor)
            .lineLimit(lineLimit)
            .truncationMode(truncationMode)
    }

    @ViewBuilder
    private var interactiveText: some View {
        Button(action: copyToPasteboard) {
            Text(textToDisplay)
                .font(font)
                .foregroundColor(currentTextColor)
                .lineLimit(lineLimit)
                .truncationMode(truncationMode)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering != isHovered {
                isHovered = hovering
                #if os(macOS)
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
                #endif
            }
        }
        .overlay(alignment: .topLeading) {
            popoverBadge
        }
        .onDisappear {
            #if os(macOS)
            if isHovered {
                NSCursor.pop()
                isHovered = false
            }
            #endif
            dismissWorkItem?.cancel()
        }
    }

    @ViewBuilder
    private var popoverBadge: some View {
        if popoverOpacity > 0 {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(resolvedAccentColor)

                    Text(popoverText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(white: 0.12).opacity(0.96))
                        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(resolvedAccentColor.opacity(0.6), lineWidth: 0.8)
                )

                // Downward-pointing pointer arrow
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 6))
                    .foregroundColor(Color(white: 0.12))
                    .padding(.leading, 12)
                    .offset(y: -1)
            }
            .fixedSize()
            .offset(y: -30)
            .opacity(popoverOpacity)
            .allowsHitTesting(false)
        }
    }

    private func copyToPasteboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(url, forType: .string)
        #endif

        onCopy?(url)

        // Cancel any pending dismissal
        dismissWorkItem?.cancel()

        // 1. Instantly become accent colored and show popover
        withAnimation(.easeOut(duration: 0.15)) {
            isCopied = true
            popoverOpacity = 1.0
        }

        // 2. Stay for 1 second, then smoothly fade out over 1 second
        let workItem = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 1.0)) {
                popoverOpacity = 0.0
                isCopied = false
            }
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }
}

/// Convenience alias for `UMUICopyableURLText`.
@available(macOS 11.0, *)
public typealias UMUICopyableLink = UMUICopyableURLText

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUICopyableURLText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            UMUICopyableURLText("https://github.com/shylock74/UMUIControls")
            UMUICopyableURLText("/Users/alexraccuglia/LocalPackage", isEnabled: false)
        }
        .padding(40)
        .frame(width: 400)
    }
}
#endif
