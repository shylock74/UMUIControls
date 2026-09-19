//
//  UMUIStatusPill.swift
//  UMUIControls
//
//  A compact capsule badge that tells the state of something at a glance
//  ("Clarification in Progress", "Ready to Generate", "Missing"), with an
//  optional pulsing dot for states that are still moving.
//

import SwiftUI

/// Color theme of a `UMUIStatusPill`.
@available(macOS 11.0, *)
public enum UMUIStatusPillStyle: Sendable, Equatable {
    /// Gray: idle, informational.
    case neutral

    /// System accent color: active, selected.
    case accent

    /// Green: done, verified, ready.
    case success

    /// Orange: needs attention.
    case warning

    /// Red: failed, missing.
    case danger

    /// Any other color.
    case custom(Color)

    var color: Color {
        switch self {
        case .neutral: return .secondary
        case .accent: return .accentColor
        case .success: return .green
        case .warning: return .orange
        case .danger: return .red
        case .custom(let color): return color
        }
    }
}

/// A tinted capsule with an optional SF Symbol or pulsing activity dot.
///
/// Usage:
/// ```swift
/// UMUIStatusPill("Clarification in Progress", style: .warning, isPulsing: true)
/// UMUIStatusPill("Ready to Generate", systemImage: "checkmark.seal.fill", style: .success)
/// ```
@available(macOS 11.0, *)
public struct UMUIStatusPill: View {
    /// The pill text.
    public let title: String

    /// Optional leading SF Symbol. Ignored while `isPulsing` is on.
    public let systemImage: String?

    /// Color theme.
    public let style: UMUIStatusPillStyle

    /// Shows a breathing dot in place of the symbol, for work in progress.
    public let isPulsing: Bool

    @State private var pulse = false

    public init(
        _ title: String,
        systemImage: String? = nil,
        style: UMUIStatusPillStyle = .neutral,
        isPulsing: Bool = false
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isPulsing = isPulsing
    }

    public var body: some View {
        HStack(spacing: 5) {
            if isPulsing {
                Circle()
                    .fill(style.color)
                    .frame(width: 6, height: 6)
                    .opacity(pulse ? 0.25 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                    .onAppear { pulse = true }
            } else if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 9, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundColor(style.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(style.color.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(style.color.opacity(0.35), lineWidth: 0.5)
        )
        .fixedSize()
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIStatusPill_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 8) {
            UMUIStatusPill("Clarification in Progress", style: .warning, isPulsing: true)
            UMUIStatusPill("Ready to Generate", systemImage: "checkmark.seal.fill", style: .success)
            UMUIStatusPill("Missing", systemImage: "exclamationmark.triangle.fill", style: .danger)
            UMUIStatusPill("7 slides", style: .neutral)
            UMUIStatusPill("Selected", style: .accent)
        }
        .padding(20)
    }
}
#endif
