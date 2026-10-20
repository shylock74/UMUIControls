//
//  UMUIIconButton.swift
//  UMUIControls
//
//  22x22 icon-only buttons for inspector rows.
//

import SwiftUI

/// A 22x22 button with a single 11pt SF Symbol.
@available(macOS 11.0, *)
public struct UMUIIconButton: View {

    public let systemImage: String
    public let help: String?
    public let action: () -> Void
    @State private var isHovered = false
    @Environment(\.umAccentColor) private var envAccentColor
    @Environment(\.umSecondaryColor) private var envSecondaryColor

    public init(_ systemImage: String, help: String? = nil, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.help = help
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 11))
                .frame(width: 22, height: 22)
                .background(backgroundView)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help(help ?? "")
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isHovered, let secondary = envSecondaryColor {
            let accent = envAccentColor ?? .accentColor
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [accent.opacity(0.22), secondary.opacity(0.22)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        } else {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.secondary.opacity(isHovered ? 0.22 : 0.0))
        }
    }
}

/// A 22x22 toggle with a single 11pt SF Symbol; the accent fills it while on.
@available(macOS 11.0, *)
public struct UMUIIconToggle: View {

    public let systemImage: String
    public let help: String?
    @Binding public var isOn: Bool
    @Environment(\.umAccentColor) private var envAccentColor
    @Environment(\.umSecondaryColor) private var envSecondaryColor
    @Environment(\.self) private var environment

    public init(_ systemImage: String, isOn: Binding<Bool>, help: String? = nil) {
        self.systemImage = systemImage
        self._isOn = isOn
        self.help = help
    }

    public var body: some View {
        Button { isOn.toggle() } label: {
            Image(systemName: systemImage)
                .font(.system(size: 11))
                .foregroundColor(foregroundColor)
                .frame(width: 22, height: 22)
                .background(backgroundView)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help ?? "")
    }

    private var foregroundColor: Color {
        guard isOn else { return .primary }
        let accent = envAccentColor ?? .accentColor
        if let secondary = envSecondaryColor {
            return accent.umContrastingTextColor(secondary: secondary, in: environment)
        }
        return .white
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isOn {
            let accent = envAccentColor ?? .accentColor
            if let secondary = envSecondaryColor {
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [accent, secondary]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(accent)
            }
        } else {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.secondary.opacity(0.14))
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIIconButton_Previews: PreviewProvider {
    struct ToggleContainer: View {
        @State private var isOn1 = true
        @State private var isOn2 = true
        
        var body: some View {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    UMUIIconButton("scissors") { }
                    UMUIIconToggle("bold", isOn: $isOn1)
                }
                
                HStack(spacing: 10) {
                    UMUIIconButton("scissors") { }
                    UMUIIconToggle("bold", isOn: $isOn2)
                }
                .umAccentColor(.blue, secondary: .purple)
            }
            .padding()
        }
    }
    
    static var previews: some View {
        ToggleContainer()
    }
}
#endif
