//
//  UMUISection.swift
//  UMUIControls
//
//  A visual grouping container with an optional title, divider, and rounded border.
//  Ideal for inspector panels and settings views.
//

import SwiftUI

/// A bordered section container with an optional title header.
///
/// Content is laid out vertically with consistent padding and a subtle rounded border.
///
/// Usage:
/// ```swift
/// UMUISection("Transform") {
///     UMUINumberControl(title: "Scale", value: $scale, range: 0.05...3.0, isPercentage: true)
///     UMUINumberControl(title: "Rotation", value: $rotation, range: -180...180)
/// }
///
/// UMUISection {
///     Text("No title section")
/// }
/// ```
public struct UMUISection<Content: View>: View {
    /// The optional section title displayed at the top.
    public let title: String?
    
    /// The content views inside the section.
    public let content: Content
    
    /// Creates a section with an optional title.
    /// - Parameters:
    ///   - title: An optional title string displayed at the top of the section.
    ///   - content: A `@ViewBuilder` closure providing the section content.
    public init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title = title {
                Text(title)
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 6)
                    .padding(.horizontal, 8)
                Divider()
            }
            content
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}
