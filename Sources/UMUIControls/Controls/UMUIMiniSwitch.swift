//
//  UMUIMiniSwitch.swift
//  UMUIControls
//
//  A compact toggle switch with a caption-sized label.
//  Uses `.controlSize(.mini)` for the most compact representation.
//

import SwiftUI

/// Sizing modes for switches.
@available(macOS 11.0, *)
public enum UMUISwitchSize: Sendable, Equatable {
    case normal
    case small
}

/// A mini-sized toggle with an inline label.
///
/// Usage:
/// ```swift
/// UMUIMiniSwitch("Force Aspect Ratio", isOn: $isForced, size: .normal)
/// ```
@available(macOS 11.0, *)
public struct UMUIMiniSwitch: View {
    /// The label text displayed beside the toggle.
    public let title: String
    
    /// Binding to the toggle state.
    @Binding public var isOn: Bool
    
    /// The sizing mode of the switch.
    public let size: UMUISwitchSize
    
    /// Creates a mini switch.
    /// - Parameters:
    ///   - title: The label text.
    ///   - isOn: Binding to the boolean state.
    ///   - size: Sizing mode (default is `.normal`).
    public init (
        _ title: String,
        isOn: Binding <Bool>,
        size: UMUISwitchSize = .small
    ) {
        self.title = title
        self._isOn = isOn
        self.size = size
    }
    
    public var body: some View {
        HStack (spacing: 8) {
            Toggle (
                "",
                isOn: $isOn
            )
            .labelsHidden ()
            .controlSize (size == .normal ? .small : .mini)
            .toggleStyle (.switch)
            .scaleEffect (
                size == .normal ? 0.85 : 0.75
            )
            .frame (
                width: size == .normal ? 32 : 28,
                height: size == .normal ? 18 : 16
            )
            
            Text (title)
                .font (size == .normal ? .body : .caption)
        }
    }
}
