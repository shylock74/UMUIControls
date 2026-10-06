//
//  UMUICapsuleButton.swift
//  UMUIControls
//
//  A customizable capsule-shaped button with a soft tinted fill, matching text color,
//  hover and press animations, and support for accent, gray, and custom colors.
//

import SwiftUI

/// The styling options for `UMUICapsuleButton`.
@available(macOS 11.0, *)
public enum UMUICapsuleButtonStyle: Sendable, Equatable {
    /// A neutral gray background with black or white text depending on contrast.
    case gray
    
    /// The application's accent color background with black or white text depending on contrast.
    case accent
    
    /// A custom background color with black or white text automatically calculated for optimal contrast.
    case custom(Color)
}

/// The sizing options for `UMUICapsuleButton`.
@available(macOS 11.0, *)
public enum UMUICapsuleButtonSize: Sendable, Equatable {
    /// Large size using standard `.title` font and larger padding.
    case large
    
    /// Normal size (default) using standard `.body` font and standard padding.
    case normal
    
    /// Small size using standard `.caption` font and smaller padding.
    case small
}

/// A capsule-shaped button control with customizable styles and responsive interactive states.
///
/// Features dynamic contrast calculation to ensure text is always readable (white or black)
/// depending on the background style.
///
/// > [!IMPORTANT]
/// > **Memory Safety:** If the `action` closure captures reference types (like view controllers
/// > or view models), ensure you capture them weakly (e.g. `[weak self]`) to prevent strong reference cycles and memory leaks.
///
/// Usage:
/// ```swift
/// UMUICapsuleButton("Save Changes", style: .accent) { [weak self] in
///     self?.saveChanges()
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUICapsuleButton<Label: View>: View {
    /// The style option for the button.
    public let style: UMUICapsuleButtonStyle
    
    /// The size option for the button (.large, .normal, or .small).
    public let size: UMUICapsuleButtonSize
    
    /// Whether the button carries a soft, slowly pulsing halo in its own colour.
    public let glow: Bool
    
    /// The action to perform when tapped.
    public let action: () -> Void
    
    /// The content inside the button.
    public let label: Label
    
    @State private var isHovered = false
    
    /// Creates a capsule button with custom content.
    /// - Parameters:
    ///   - style: The style (gray, accent, or custom).
    ///   - size: The size option (.large, .normal, or .small).
    ///   - glow: Adds a pulsing halo so the button reads as the primary action.
    ///   - action: The action to perform when tapped.
    ///   - label: The content inside the button.
    public init(
        style: UMUICapsuleButtonStyle = .gray,
        size: UMUICapsuleButtonSize = .small,
        glow: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.style = style
        self.size = size
        self.glow = glow
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(CapsuleButtonStyle(style: style, size: size, glow: glow, isHovered: isHovered))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

@available(macOS 11.0, *)
public extension UMUICapsuleButton where Label == Text {
    /// Creates a capsule button with a text title.
    /// - Parameters:
    ///   - title: The label text of the button.
    ///   - style: The style (gray, accent, or custom).
    ///   - size: The size option (.large, .normal, or .small).
    ///   - action: The action to perform when tapped.
    init(
        _ title: String,
        style: UMUICapsuleButtonStyle = .gray,
        size: UMUICapsuleButtonSize = .small,
        glow: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(style: style, size: size, glow: glow, action: action) {
            Text(title)
        }
    }
}

@available(macOS 11.0, *)
public extension UMUICapsuleButton where Label == SwiftUI.Label<Text, Image> {
    /// Creates a capsule button with a title and a system image.
    /// - Parameters:
    ///   - title: The label text of the button.
    ///   - systemImage: The name of the SF Symbol.
    ///   - style: The style (gray, accent, or custom).
    ///   - size: The size option (.large, .normal, or .small).
    ///   - action: The action to perform when tapped.
    init(
        _ title: String,
        systemImage: String,
        style: UMUICapsuleButtonStyle = .gray,
        size: UMUICapsuleButtonSize = .small,
        glow: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(style: style, size: size, glow: glow, action: action) {
            SwiftUI.Label(title, systemImage: systemImage)
        }
    }
}

// MARK: - Button Style Implementation

@available(macOS 11.0, *)
struct CapsuleButtonStyle: ButtonStyle {
    let style: UMUICapsuleButtonStyle
    let size: UMUICapsuleButtonSize
    let glow: Bool
    let isHovered: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.self) private var environment
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let tint = resolveTintColor()
        let foregroundColor = resolveForegroundColor(tint: tint)
        let fillColor = resolveFillColor(tint: tint, isPressed: isPressed)
        
        let scale: CGFloat = isPressed ? 0.98 : 1.0
        
        return configuration.label
            .font(fontForSize.weight(.medium))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                Capsule()
                    .fill(fillColor)
            )
            .background(
                UMUICapsuleGlow(color: tint, isHovered: isHovered, isPressed: isPressed)
                    .opacity(glow ? 1 : 0)
            )
            .scaleEffect(scale)
            .opacity(isEnabled ? 1.0 : 0.4)
            .animation(.easeOut(duration: 0.15), value: isPressed)
            .animation(.easeOut(duration: 0.15), value: isHovered)
    }
    
    private var fontForSize: Font {
        switch size {
        case .large:
            return .title
        case .normal:
            return .body
        case .small:
            return .caption
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .large:
            return 24
        case .normal:
            return 16
        case .small:
            return 12
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .large:
            return 12
        case .normal:
            return 8
        case .small:
            return 6
        }
    }
    
    /// The base colour of the style (used for the tinted fill, text and glow).
    private func resolveTintColor() -> Color {
        switch style {
        case .gray:
            return colorScheme == .dark ? Color.white : Color.black
        case .accent:
            return environment.umAccentColor ?? .accentColor
        case .custom(let color):
            return color
        }
    }
    
    private func resolveFillColor(tint: Color, isPressed: Bool) -> Color {
        let isGray = style == .gray
        let base: Double = isGray ? 0.08 : 0.14
        let step: Double = isGray ? 0.06 : 0.07
        if isPressed {
            return tint.opacity(base + step * 2)
        } else if isHovered && isEnabled {
            return tint.opacity(base + step)
        }
        return tint.opacity(base)
    }
    
    private func resolveForegroundColor(tint: Color) -> Color {
        switch style {
        case .gray:
            return colorScheme == .dark ? Color(white: 0.82) : Color(white: 0.25)
        default:
            return tint
        }
    }
}

// MARK: - Glow Halo

/// The soft, slowly breathing halo drawn behind a glowing capsule button.
/// It is purely decorative and never takes hits, so the button below stays clickable.
@available(macOS 11.0, *)
struct UMUICapsuleGlow: View {
    let color: Color
    let isHovered: Bool
    let isPressed: Bool
    
    @State private var breathing = false
    
    var body: some View {
        // Pressing dims the halo so the button still reads as pushed in.
        let intensity: Double = isPressed ? 0.30 : (isHovered ? 0.85 : 0.55)
        
        Capsule()
            .fill(color)
            .blur(radius: isHovered ? 16 : 12)
            .opacity(intensity * (breathing ? 1.0 : 0.55))
            .scaleEffect(breathing ? 1.10 : 1.0)
            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: breathing)
            .allowsHitTesting(false)
            .onAppear { breathing = true }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUICapsuleButton_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("UMUICapsuleButton Previews")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sizes (.large, .normal, .small)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .bottom, spacing: 12) {
                        UMUICapsuleButton("Large Button", style: .accent, size: .large) {
                            print("Large button clicked")
                        }
                        
                        UMUICapsuleButton("Normal Button", style: .accent, size: .normal) {
                            print("Normal button clicked")
                        }
                        
                        UMUICapsuleButton("Small Button", style: .accent, size: .small) {
                            print("Small button clicked")
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Styles (Gray, Accent, Custom Colors)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 15) {
                        UMUICapsuleButton("Gray Button", style: .gray) {
                            print("Gray button clicked")
                        }
                        
                        UMUICapsuleButton("Accent Button", style: .accent) {
                            print("Accent button clicked")
                        }
                        
                        UMUICapsuleButton("Yellow Custom", style: .custom(.yellow)) {
                            print("Yellow button clicked")
                        }
                        
                        UMUICapsuleButton("Purple Custom", style: .custom(.purple)) {
                            print("Purple button clicked")
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Icons & Custom Views")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 15) {
                        UMUICapsuleButton("With Icon", systemImage: "star.fill", style: .accent, size: .normal) {
                            print("Star button clicked")
                        }
                        
                        UMUICapsuleButton(style: .gray, size: .normal) {
                            print("Custom content clicked")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "paperplane.fill")
                                Text("Send")
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                }
            }
            .padding(30)
        }
        .frame(width: 550, height: 450)
    }
}
#endif
