//
//  UMUIMiniButton.swift
//  UMUIControls
//
//  A compact capsule-outlined button for dense/restricted user interfaces.
//

import SwiftUI

/// The styling options for `UMUIMiniButton`.
@available(macOS 11.0, *)
public enum UMUIMiniButtonStyle: Sendable, Equatable {
    /// A neutral gray outline.
    case gray
    
    /// The application's accent color outline.
    case accent
    
    /// A custom outline color.
    case custom(Color)
}

/// A compact capsule-shaped outline button with responsive interactive hover and click states.
///
/// Features:
/// - Outline design with a 1.0pt stroke width.
/// - Fixed 11pt regular font (non-bold).
/// - 6pt horizontal and 2pt vertical padding.
/// - Sfondo semitrasparente: 10% opacity on hover, 20% opacity on press.
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
    /// Creates a mini button with an icon and a text title (spaced at 4pt).
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
            HStack(spacing: 4) {
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
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let baseColor = resolveColor()
        
        // Transparent by default, 10% opacity on hover, 20% opacity on press
        let bgOpacity: Double = isPressed ? 0.2 : (isHovered && isEnabled ? 0.1 : 0.0)
        let strokeColor = baseColor.opacity(isEnabled ? 1.0 : 0.4)
        
        return configuration.label
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(strokeColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(baseColor.opacity(bgOpacity))
            )
            .overlay(
                Capsule()
                    .strokeBorder(strokeColor, lineWidth: 1.0)
            )
            .animation(.easeOut(duration: 0.15), value: isPressed)
            .animation(.easeOut(duration: 0.15), value: isHovered)
    }
    
    private func resolveColor() -> Color {
        switch style {
        case .gray:
            return colorScheme == .dark ? Color(white: 0.65) : Color(white: 0.4)
        case .accent:
            return .accentColor
        case .custom(let color):
            return color
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
        .frame(width: 350, height: 250)
    }
}
#endif
