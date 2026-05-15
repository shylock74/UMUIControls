//
//  UMUICaptionText.swift
//  UMUIControls
//
//  Text view shorthands for common caption styles.
//

import SwiftUI

/// A text view styled with the `.caption` font.
///
/// Usage:
/// ```swift
/// UMUICaptionText("Name")
/// ```
public struct UMUICaptionText: View {
    public let text: String
    
    public init(_ text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
    }
}

/// A text view styled with the `.caption` font and `.secondary` foreground color.
///
/// Usage:
/// ```swift
/// UMUICaptionGrayText("px")
/// ```
public struct UMUICaptionGrayText: View {
    public let text: String
    
    public init(_ text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
