//
//  UMUITheme.swift
//  UMUIControls
//
//  Design tokens (surfaces, strokes, text, accent, state colors, type scale,
//  spacing, radii) shared by every UMUI control. Inject a theme with
//  `.umuiTheme(_:)`; read it with `@Environment(\.umuiTheme)`.
//  Existing controls keep their current look until they adopt the tokens.
//

import SwiftUI

/// Design tokens for UMUI. Value type: copy and tweak to build a variant.
@available(macOS 11.0, *)
public struct UMUITheme: Equatable, Sendable {

    // MARK: Surfaces (darkest to lightest)

    /// Window background.
    public var surfaceWindow: Color
    /// Panels, sidebars, inspector.
    public var surfacePanel: Color
    /// Cards and popovers.
    public var surfaceRaised: Color
    /// Fields, segmented tracks, secondary buttons.
    public var surfaceControl: Color
    /// Hover / pressed state of a control.
    public var surfaceHover: Color

    // MARK: Strokes

    /// Hairline separators.
    public var strokeSubtle: Color
    /// Borders of focused or drop-target areas.
    public var strokeStrong: Color

    // MARK: Text

    public var textPrimary: Color
    public var textSecondary: Color
    public var textTertiary: Color
    public var textDisabled: Color

    // MARK: Accent

    /// Fill behind white text (primary buttons, selected tab).
    public var accentFill: Color
    /// Accent for text and icons on dark surfaces.
    public var accentText: Color
    /// Soft accent for selected rows.
    public var accentSubtle: Color

    // MARK: State colors (one meaning per hue)

    public var stateHero: Color
    public var stateForced: Color
    public var stateIgnored: Color
    public var stateCut: Color
    public var stateWarning: Color
    public var destructive: Color

    // MARK: Type scale (points)

    public var captionSize: CGFloat
    public var footnoteSize: CGFloat
    public var bodySize: CGFloat
    public var titleSize: CGFloat
    public var displaySize: CGFloat

    // MARK: Spacing (4-pt grid) and radii

    public var space1: CGFloat
    public var space2: CGFloat
    public var space3: CGFloat
    public var space4: CGFloat
    public var space6: CGFloat
    public var space8: CGFloat

    public var radiusSmall: CGFloat
    public var radiusControl: CGFloat
    public var radiusCard: CGFloat

    // MARK: Fonts

    public var captionFont: Font { .system(size: captionSize, weight: .medium) }
    public var footnoteFont: Font { .system(size: footnoteSize) }
    public var bodyFont: Font { .system(size: bodySize) }
    public var headlineFont: Font { .system(size: bodySize, weight: .semibold) }
    public var titleFont: Font { .system(size: titleSize, weight: .semibold) }
    public var displayFont: Font { .system(size: displaySize, weight: .semibold).monospacedDigit() }

    // MARK: Presets

    /// Neutral dark theme with an orange accent (BeatMark Pro look).
    public static let proDark = UMUITheme(
        surfaceWindow:   Color(white: 0.10),
        surfacePanel:    Color(white: 0.12),
        surfaceRaised:   Color(white: 0.16),
        surfaceControl:  Color(white: 0.20),
        surfaceHover:    Color(white: 0.24),
        strokeSubtle:    Color.white.opacity(0.08),
        strokeStrong:    Color.white.opacity(0.20),
        textPrimary:     Color.white.opacity(0.92),
        textSecondary:   Color.white.opacity(0.65),
        textTertiary:    Color.white.opacity(0.45),
        textDisabled:    Color.white.opacity(0.30),
        accentFill:      Color(red: 0.93, green: 0.42, blue: 0.10),
        accentText:      Color(red: 1.00, green: 0.58, blue: 0.25),
        accentSubtle:    Color(red: 0.93, green: 0.42, blue: 0.10).opacity(0.20),
        stateHero:       Color(red: 1.00, green: 0.80, blue: 0.20),
        stateForced:     Color(red: 0.30, green: 0.80, blue: 0.40),
        stateIgnored:    Color.white.opacity(0.45),
        stateCut:        Color(red: 0.25, green: 0.75, blue: 0.95),
        stateWarning:    Color(red: 1.00, green: 0.30, blue: 0.28),
        destructive:     Color(red: 1.00, green: 0.35, blue: 0.31),
        captionSize: 10, footnoteSize: 11, bodySize: 13, titleSize: 15, displaySize: 24,
        space1: 4, space2: 8, space3: 12, space4: 16, space6: 24, space8: 32,
        radiusSmall: 4, radiusControl: 6, radiusCard: 10
    )

    /// Default theme: same as `proDark`.
    public static let `default` = UMUITheme.proDark
}

// MARK: - Environment

@available(macOS 11.0, *)
private struct UMUIThemeKey: EnvironmentKey {
    static let defaultValue = UMUITheme.default
}

@available(macOS 11.0, *)
extension EnvironmentValues {
    /// The active UMUI theme.
    public var umuiTheme: UMUITheme {
        get { self[UMUIThemeKey.self] }
        set { self[UMUIThemeKey.self] = newValue }
    }
}

@available(macOS 11.0, *)
extension View {
    /// Sets the UMUI theme for this view and its descendants.
    public func umuiTheme(_ theme: UMUITheme) -> some View {
        environment(\.umuiTheme, theme)
    }
}
