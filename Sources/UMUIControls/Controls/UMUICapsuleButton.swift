//
//  UMUICapsuleButton.swift
//  UMUIControls
//
//  A customizable capsule-shaped button featuring dynamic text color contrast,
//  hover and press animations, and support for accent, gray, and custom colors.
//

import SwiftUI

/// The styling options for `UMUICapsuleButton`.
public enum UMUICapsuleButtonStyle: Sendable, Equatable {
    /// A neutral gray background with black or white text depending on contrast.
    case gray
    
    /// The application's accent color background with black or white text depending on contrast.
    case accent
    
    /// A custom background color with black or white text automatically calculated for optimal contrast.
    case custom(Color)
}

/// The sizing options for `UMUICapsuleButton`.
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
public struct UMUICapsuleButton<Label: View>: View {
    /// The style option for the button.
    public let style: UMUICapsuleButtonStyle
    
    /// The size option for the button (.large, .normal, or .small).
    public let size: UMUICapsuleButtonSize
    
    /// The action to perform when tapped.
    public let action: () -> Void
    
    /// The content inside the button.
    public let label: Label
    
    @State private var isHovered = false
    
    /// Creates a capsule button with custom content.
    /// - Parameters:
    ///   - style: The style (gray, accent, or custom).
    ///   - size: The size option (.large, .normal, or .small).
    ///   - action: The action to perform when tapped.
    ///   - label: The content inside the button.
    public init(
        style: UMUICapsuleButtonStyle = .gray,
        size: UMUICapsuleButtonSize = .small,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.style = style
        self.size = size
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(CapsuleButtonStyle(style: style, size: size, isHovered: isHovered))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

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
        action: @escaping () -> Void
    ) {
        self.init(style: style, size: size, action: action) {
            Text(title)
        }
    }
}

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
        action: @escaping () -> Void
    ) {
        self.init(style: style, size: size, action: action) {
            SwiftUI.Label(title, systemImage: systemImage)
        }
    }
}

// MARK: - Button Style Implementation

struct CapsuleButtonStyle: ButtonStyle {
    let style: UMUICapsuleButtonStyle
    let size: UMUICapsuleButtonSize
    let isHovered: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.self) private var environment
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        let backgroundColor = resolveBackgroundColor()
        let foregroundColor = resolveForegroundColor(backgroundColor: backgroundColor)
        
        // Interactive tactile micro-animations
        let scale: CGFloat = isPressed ? 0.96 : (isHovered ? 1.02 : 1.0)
        let brightnessChange: Double = isPressed ? -0.08 : (isHovered ? 0.04 : 0.0)
        let shadowOpacity: Double = isHovered && !isPressed ? 0.15 : 0.0
        
        return configuration.label
            .font(fontForSize.weight(.semibold))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                Capsule()
                    .fill(backgroundColor)
                    .brightness(brightnessChange)
            )
            .scaleEffect(scale)
            .shadow(color: Color.black.opacity(shadowOpacity), radius: 4, x: 0, y: isHovered ? 2 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
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
    
    private func resolveBackgroundColor() -> Color {
        switch style {
        case .gray:
            return colorScheme == .dark ? Color(white: 0.22) : Color(white: 0.90)
        case .accent:
            return .accentColor
        case .custom(let color):
            return color
        }
    }
    
    private func resolveForegroundColor(backgroundColor: Color) -> Color {
        return backgroundColor.contrastingTextColor(in: environment)
    }
}

// MARK: - Color Extension for Relative Luminance

public extension Color {
    /// Returns either `.black` or `.white` depending on which provides better contrast against this color.
    func contrastingTextColor(in environment: EnvironmentValues) -> Color {
        #if os(macOS)
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return .white
        }
        let r = Double(rgbColor.redComponent)
        let g = Double(rgbColor.greenComponent)
        let b = Double(rgbColor.blueComponent)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.5 ? .black : .white
        #else
        return .white
        #endif
    }
}

// MARK: - Previews

#if DEBUG
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
