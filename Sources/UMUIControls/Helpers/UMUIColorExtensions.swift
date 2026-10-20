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
    
    /// Returns the relative luminance (0.0 to 1.0) of this color.
    var umLuminance: Double {
        #if os(macOS)
        let resolvedNSColor = resolveToNSColor()
        guard let rgbColor = resolvedNSColor.usingColorSpace(.deviceRGB) else {
            return 0.0
        }
        let r = Double(rgbColor.redComponent)
        let g = Double(rgbColor.greenComponent)
        let b = Double(rgbColor.blueComponent)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
        #else
        return 0.0
        #endif
    }
    
    /// Returns the relative luminance of this color, taking environment overrides into account.
    func umLuminance(in environment: EnvironmentValues? = nil) -> Double {
        if self == .accentColor, let customAccent = environment?.umAccentColor {
            return customAccent.umLuminance
        }
        return umLuminance
    }

    /// Returns true if this color has a relative luminance > 0.5, indicating dark foreground content should be used.
    var umIsLight: Bool {
        umLuminance > 0.5
    }
    
    /// Returns true if this color is light, optionally taking environment overrides into account.
    func umIsLight(in environment: EnvironmentValues? = nil) -> Bool {
        umLuminance(in: environment) > 0.5
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
    
    /// Returns either `Color.darkGray` or `Color.white` depending on which provides better contrast against a gradient between this color and an optional secondary color.
    func umContrastingTextColor(secondary: Color?, in environment: EnvironmentValues? = nil) -> Color {
        guard let secondary = secondary else {
            return umContrastingTextColor(in: environment)
        }
        let lum1 = self.umLuminance(in: environment)
        let lum2 = secondary.umLuminance(in: environment)
        let avgLum = (lum1 + lum2) / 2.0
        return avgLum > 0.5 ? .darkGray : .white
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

private struct UMSecondaryColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(macOS 11.0, *)
public extension EnvironmentValues {
    /// Custom accent color passed through the view hierarchy for UMUIControls.
    var umAccentColor: Color? {
        get { self[UMAccentColorKey.self] }
        set { self[UMAccentColorKey.self] = newValue }
    }
    
    /// Custom secondary color passed through the view hierarchy for UMUIControls gradient buttons.
    var umSecondaryColor: Color? {
        get { self[UMSecondaryColorKey.self] }
        set { self[UMSecondaryColorKey.self] = newValue }
    }
}

@available(macOS 11.0, *)
public extension View {
    /// Sets the accent color for UMUIControls components in this view hierarchy.
    func umAccentColor(_ color: Color) -> some View {
        environment(\.umAccentColor, color)
            .accentColor(color)
    }
    
    /// Sets the secondary color for UMUIControls components in this view hierarchy.
    func umSecondaryColor(_ color: Color?) -> some View {
        environment(\.umSecondaryColor, color)
    }
    
    /// Sets both the accent and optional secondary color for UMUIControls components in this view hierarchy.
    func umAccentColor(_ accent: Color, secondary: Color?) -> some View {
        self.umAccentColor(accent)
            .umSecondaryColor(secondary)
    }
}
