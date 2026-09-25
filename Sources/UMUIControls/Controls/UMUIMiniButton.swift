//
//  UMUIMiniButton.swift
//  UMUIControls
//
//  A compact capsule soft-pill button for dense/restricted user interfaces.
//

import SwiftUI

/// The styling options for `UMUIMiniButton`.
@available(macOS 11.0, *)
public enum UMUIMiniButtonStyle: Sendable, Equatable {
    /// A neutral gray soft-pill.
    case gray
    
    /// The application's accent color soft-pill.
    case accent
    
    /// A custom color soft-pill.
    case custom(Color)
}

/// A compact capsule-shaped button with a soft pill styling and responsive interactive hover and click states.
///
/// Features:
/// - Soft pill styling with subtle, non-intrusive hairline border.
/// - Highly legible 11pt medium-weight typography.
/// - 8pt horizontal and 3pt vertical padding with 5pt icon-text spacing.
/// - Semitransparent background fill with interactive hover and click states.
/// - Supports custom views, text-only, and text + SF Symbol initializers.
///
/// Usage:
/// ```swift
/// UMUIMiniButton("Edit", style: .accent) {
///     print("Clicked")
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIMiniButton<Label: View>: View {
    /// The style option for the button.
    public let style: UMUIMiniButtonStyle
    
    /// The action to perform when tapped.
    public let action: () -> Void
    
    /// The content inside the button.
    public let label: Label
    
    @State private var isHovered = false
    
    /// Creates a mini button with custom content.
    /// - Parameters:
    ///   - style: The style (gray, accent, or custom).
    ///   - action: The action to perform when tapped.
    ///   - label: The content inside the button.
    public init(
        style: UMUIMiniButtonStyle = .gray,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.style = style
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(MiniButtonStyle(style: style, isHovered: isHovered))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

@available(macOS 11.0, *)
public extension UMUIMiniButton where Label == Text {
    /// Creates a mini button with a text title.
    /// - Parameters:
    ///   - title: The label text of the button.
    ///   - style: The style (gray, accent, or custom).
    ///   - action: The action to perform when tapped.
    init(
        _ title: String,
        style: UMUIMiniButtonStyle = .gray,
        action: @escaping () -> Void
    ) {
        self.init(style: style, action: action) {
            Text(title)
        }
    }
}

@available(macOS 11.0, *)
public extension UMUIMiniButton where Label == HStack<TupleView<(Image, Text)>> {
    /// Creates a mini button with an icon and a text title (spaced at 5pt).
    /// - Parameters:
    ///   - title: The label text of the button.
    ///   - systemImage: The name of the SF Symbol.
    ///   - style: The style (gray, accent, or custom).
    ///   - action: The action to perform when tapped.
    init(
        _ title: String,
        systemImage: String,
        style: UMUIMiniButtonStyle = .gray,
        action: @escaping () -> Void
    ) {
        self.init(style: style, action: action) {
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                Text(title)
            }
        }
    }
}

// MARK: - Button Style Implementation

@available(macOS 11.0, *)
struct MiniButtonStyle: ButtonStyle {
    let style: UMUIMiniButtonStyle
    let isHovered: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.umAccentColor) private var envAccentColor
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let fgColor = resolveForegroundColor()
        let bgColor = resolveBackgroundColor(isPressed: isPressed)
        let strokeColor = resolveStrokeColor()
        
        return configuration.label
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(fgColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(bgColor)
            )
            .overlay(
                Capsule()
                    .strokeBorder(strokeColor, lineWidth: 0.75)
            )
            .opacity(isEnabled ? 1.0 : 0.4)
            .animation(.easeOut(duration: 0.15), value: isPressed)
            .animation(.easeOut(duration: 0.15), value: isHovered)
    }
    
    private func resolveForegroundColor() -> Color {
        switch style {
        case .gray:
            return colorScheme == .dark ? Color(white: 0.78) : Color(white: 0.28)
        case .accent:
            return envAccentColor ?? .accentColor
        case .custom(let color):
            return color
        }
    }
    
    private func resolveBackgroundColor(isPressed: Bool) -> Color {
        switch style {
        case .gray:
            if isPressed {
                return colorScheme == .dark ? Color.white.opacity(0.20) : Color.black.opacity(0.15)
            } else if isHovered && isEnabled {
                return colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.09)
            } else {
                return colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
            }
        case .accent:
            let base = envAccentColor ?? .accentColor
            if isPressed {
                return base.opacity(0.28)
            } else if isHovered && isEnabled {
                return base.opacity(0.20)
            } else {
                return base.opacity(0.12)
            }
        case .custom(let color):
            if isPressed {
                return color.opacity(0.28)
            } else if isHovered && isEnabled {
                return color.opacity(0.20)
            } else {
                return color.opacity(0.12)
            }
        }
    }
    
    private func resolveStrokeColor() -> Color {
        switch style {
        case .gray:
            return colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)
        case .accent:
            let base = envAccentColor ?? .accentColor
            return base.opacity(0.22)
        case .custom(let color):
            return color.opacity(0.22)
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIMiniButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("UMUIMiniButton Previews")
                .font(.headline)
            
            HStack(spacing: 10) {
                UMUIMiniButton("Gray", style: .gray) {
                    print("Gray clicked")
                }
                
                UMUIMiniButton("Accent", style: .accent) {
                    print("Accent clicked")
                }
                
                UMUIMiniButton("Custom Red", style: .custom(.red)) {
                    print("Red clicked")
                }
            }
            
            HStack(spacing: 10) {
                UMUIMiniButton("Actions", systemImage: "slider.horizontal.3", style: .gray) {
                    print("Actions clicked")
                }
                
                UMUIMiniButton("Play", systemImage: "play.fill", style: .accent) {
                    print("Play clicked")
                }
                
                UMUIMiniButton("Settings", systemImage: "gearshape", style: .gray) {
                    print("Settings clicked")
                }
            }
            
            HStack(spacing: 10) {
                UMUIMiniButton("Disabled Gray", style: .gray) { }
                    .disabled(true)
                
                UMUIMiniButton("Disabled Accent", style: .accent) { }
                    .disabled(true)
            }
        }
        .padding()
        .frame(width: 400, height: 260)
    }
}
#endif
