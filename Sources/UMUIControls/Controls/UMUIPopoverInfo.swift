//
//  UMUIPopoverInfo.swift
//  UMUIControls
//
//  A small "i" trigger that reveals a longer explanation on demand, so a
//  paragraph of help text does not have to sit in the layout permanently.
//

import SwiftUI

/// A plain `info.circle` button that opens a popover with explanatory text.
///
/// Usage:
/// ```swift
/// UMUIPopoverInfo("Rate is how often a frame is examined; a card lasts as long as the clip that should have been there, so 2 fps finds anything an editor would have noticed missing.")
/// ```
@available(macOS 12.0, *)
public struct UMUIPopoverInfo: View {
    /// The explanation shown inside the popover.
    public let text: String

    /// An optional heading shown above the text.
    public let title: String?

    /// An optional SF Symbol shown beside the text, for a warning or a pointer to what the text is about.
    public let icon: String?

    /// Maximum width of the popover's text column, so a long paragraph wraps instead of stretching the popover across the screen.
    public let width: CGFloat

    @State private var isPresented = false

    public init(_ text: String, title: String? = nil, icon: String? = nil, width: CGFloat = 260) {
        self.text = text
        self.title = title
        self.icon = icon
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
            HStack(alignment: .top, spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.system(size: 11, weight: .medium))
                    }

                    Text(text)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: width, alignment: .leading)
            .padding(12)
        }
    }
}
