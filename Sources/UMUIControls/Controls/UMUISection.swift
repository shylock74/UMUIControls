//
//  UMUISection.swift
//  UMUIControls
//
//  A visual grouping container with an optional title, divider, and rounded border.
//  Ideal for inspector panels and settings views.
//

import SwiftUI

/// Sizing modes for UMUISection.
public enum UMUISectionSize: Sendable, Equatable {
    case normal
    case small
}

/// A bordered section container with an optional title header.
///
/// Content is laid out vertically with consistent padding and a subtle rounded border.
///
/// Usage:
/// ```swift
/// UMUISection("Transform", size: .normal) {
///     UMUINumberControl(title: "Scale", value: $scale, range: 0.05...3.0, isPercentage: true)
/// }
/// ```
public struct UMUISection<Content: View>: View {
    /// The optional section title displayed at the top.
    public let title: String?
    
    /// The sizing mode of the section.
    public let size: UMUISectionSize
    
    /// The content views inside the section.
    public let content: Content
    
    /// Creates a section with an optional title.
    /// - Parameters:
    ///   - title: An optional title string displayed at the top of the section.
    ///   - size: Sizing mode (default is `.normal`).
    ///   - content: A `@ViewBuilder` closure providing the section content.
    public init(
        _ title: String? = nil,
        size: UMUISectionSize = .small,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.size = size
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: size == .normal ? 8 : 6) {
            if let title = title {
                Text(title)
                    .font(size == .normal ? .subheadline.bold() : .caption2.bold())
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, size == .normal ? 8 : 6)
                    .padding(.horizontal, size == .normal ? 10 : 8)
                Divider()
            }
            content
                .padding(.horizontal, size == .normal ? 10 : 8)
                .padding(.bottom, size == .normal ? 8 : 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}
