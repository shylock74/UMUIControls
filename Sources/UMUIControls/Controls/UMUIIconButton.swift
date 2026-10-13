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
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.secondary.opacity(isHovered ? 0.22 : 0.0))
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help(help ?? "")
    }
}

/// A 22x22 toggle with a single 11pt SF Symbol; the accent fills it while on.
@available(macOS 11.0, *)
public struct UMUIIconToggle: View {

    public let systemImage: String
    public let help: String?
    @Binding public var isOn: Bool

    public init(_ systemImage: String, isOn: Binding<Bool>, help: String? = nil) {
        self.systemImage = systemImage
        self._isOn = isOn
        self.help = help
    }

    public var body: some View {
        Button { isOn.toggle() } label: {
            Image(systemName: systemImage)
                .font(.system(size: 11))
                .foregroundColor(isOn ? .white : .primary)
                .frame(width: 22, height: 22)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isOn ? Color.accentColor : Color.secondary.opacity(0.14))
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help ?? "")
    }
}
