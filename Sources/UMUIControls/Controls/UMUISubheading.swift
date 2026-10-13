//
//  UMUISubheading.swift
//  UMUIControls
//
//  A small uppercase heading that groups the rows below it.
//

import SwiftUI

/// A 10pt semibold uppercase heading, with room above to separate it from the previous group.
///
/// Usage:
/// ```swift
/// UMUISubheading("Output")
/// ```
@available(macOS 11.0, *)
public struct UMUISubheading: View {

    public let title: String
    public let topPadding: CGFloat

    public init(_ title: String, topPadding: CGFloat = 16) {
        self.title = title
        self.topPadding = topPadding
    }

    public var body: some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .tracking(0.4)
            .foregroundColor(.secondary)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, topPadding)
            .padding(.bottom, 4)
    }
}
