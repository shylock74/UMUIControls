//
//  UMUIPopoverInfo.swift
//  UMUIControls
//
//  A small "i" trigger that reveals a longer explanation on demand, so a
//  paragraph of help text does not have to sit in the layout permanently.
//

import SwiftUI

/// A plain `info.circle` button that opens a styled popover: a bold title,
/// a tinted icon centered below it, and the explanation broken one sentence
/// per line so a long paragraph reads as a short list rather than a block.
///
/// Usage:
/// ```swift
/// UMUIPopoverInfo("Frame Rate", icon: "gauge.with.needle",
///     text: "Rate is how often a frame is examined; a card lasts as long as the clip that should have been there, so 2 fps finds anything an editor would have noticed missing.")
/// ```
@available(macOS 12.0, *)
public struct UMUIPopoverInfo: View {
    /// The popover's heading, shown large and centered above the icon.
    public let title: String

    /// The SF Symbol centered between the title and the text.
    public let icon: String

    /// The explanation, broken onto one line per sentence for readability.
    public let text: String

    /// Width of the popover, so a long paragraph wraps instead of stretching across the screen.
    public let width: CGFloat

    @State private var isPresented = false

    public init(_ title: String, icon: String, text: String, width: CGFloat = 280) {
        self.title = title
        self.icon = icon
        self.text = text
        self.width = width
    }

    public var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented, arrowEdge: .top) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .multilineTextAlignment(.center)

                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(sentences.enumerated()), id: \.offset) { _, sentence in
                        Text(sentence)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: width)
            .padding(16)
        }
    }

    /// `text` broken along locale-aware sentence boundaries — robust against a period inside a
    /// number or an abbreviation, which a naive split on `". "` is not.
    private var sentences: [String] {
        var result: [String] = []
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: [.bySentences]) { substring, _, _, _ in
            let trimmed = substring?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !trimmed.isEmpty {
                result.append(trimmed)
            }
        }
        return result.isEmpty ? [text] : result
    }
}
