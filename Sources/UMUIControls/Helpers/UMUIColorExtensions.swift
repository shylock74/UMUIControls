//
//  UMUIColorExtensions.swift
//  UMUIControls
//
//  Standardized color definitions used across controls.
//

import SwiftUI

@available(macOS 11.0, *)
public extension Color {
    /// A standardized dark gray color.
    static let darkGray = Color(white: 0.12)
    
    /// A standardized mild dark gray color.
    static let mildDarkGray = Color(white: 0.16)
    
    /// A standardized box gray color for disclosure backgrounds.
    static let boxGray = Color(white: 0.10)
    
    /// A standardized button background gray color.
    static let buttonBackgroundGray = Color(white: 0.18)
    
    /// A backward-compatible mint color.
    static var umMint: Color {
        if #available(macOS 12.0, *) {
            return Color.mint
        } else {
            // Standard system mint RGB: R: 0.0, G: 0.78, B: 0.75
            return Color(red: 0.0, green: 0.78, blue: 0.75)
        }
    }
    
    /// Returns true if this color has a relative luminance > 0.5, indicating dark foreground content should be used.
    var umIsLight: Bool {
        #if os(macOS)
        let resolvedNSColor = resolveToNSColor()
        guard let rgbColor = resolvedNSColor.usingColorSpace(.deviceRGB) else {
            return false
        }
        let r = Double(rgbColor.redComponent)
        let g = Double(rgbColor.greenComponent)
        let b = Double(rgbColor.blueComponent)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.5
        #else
        return false
        #endif
    }
    
    /// Returns true if this color is light, optionally taking environment overrides into account.
    func umIsLight(in environment: EnvironmentValues? = nil) -> Bool {
        if self == .accentColor, let customAccent = environment?.umAccentColor {
            return customAccent.umIsLight
        }
        return umIsLight
    }
    
    /// Returns either `Color.darkGray` or `Color.white` depending on which provides better contrast against this color.
    var umContrastingTextColor: Color {
        umIsLight ? .darkGray : .white
    }
    
    /// Returns either `Color.darkGray` or `Color.white` depending on which provides better contrast against this color.
    func umContrastingTextColor(in environment: EnvironmentValues? = nil) -> Color {
        if self == .accentColor, let customAccent = environment?.umAccentColor {
            return customAccent.umContrastingTextColor
        }
        return umContrastingTextColor
    }
    
    #if os(macOS)
    private func resolveToNSColor() -> NSColor {
        if self == .accentColor {
            if let assetAccent = NSColor(named: NSColor.Name("AccentColor"), bundle: Bundle.main) {
                return assetAccent
            }
            return NSColor.controlAccentColor
        }
        return NSColor(self)
    }
    #endif
}

private struct UMAccentColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(macOS 11.0, *)
public extension EnvironmentValues {
    /// Custom accent color passed through the view hierarchy for UMUIControls.
    var umAccentColor: Color? {
        get { self[UMAccentColorKey.self] }
        set { self[UMAccentColorKey.self] = newValue }
    }
}

@available(macOS 11.0, *)
public extension View {
    /// Sets the accent color for UMUIControls components in this view hierarchy.
    func umAccentColor(_ color: Color) -> some View {
        environment(\.umAccentColor, color)
            .accentColor(color)
    }
}
