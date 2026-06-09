//
//  UMUIColorExtensions.swift
//  UMUIControls
//
//  Standardized color definitions used across controls.
//

import SwiftUI

public extension Color {
    /// A standardized dark gray color.
    static let darkGray = Color(white: 0.2)
    
    /// A standardized mild dark gray color.
    static let mildDarkGray = Color(white: 0.3)
    
    /// A standardized box gray color for disclosure backgrounds.
    static let boxGray = Color(white: 0.15)
    
    /// A standardized button background gray color.
    static let buttonBackgroundGray = Color(white: 0.25)
    
    /// A backward-compatible mint color.
    static var umMint: Color {
        if #available(macOS 12.0, *) {
            return Color.mint
        } else {
            // Standard system mint RGB: R: 0.0, G: 0.78, B: 0.75
            return Color(red: 0.0, green: 0.78, blue: 0.75)
        }
    }
}
