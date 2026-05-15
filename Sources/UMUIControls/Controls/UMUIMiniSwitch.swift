//
//  UMUIMiniSwitch.swift
//  UMUIControls
//
//  A compact toggle switch with a caption-sized label.
//  Uses `.controlSize(.mini)` for the most compact representation.
//

import SwiftUI

/// A mini-sized toggle with an inline label.
///
/// Usage:
/// ```swift
/// UMUIMiniSwitch("Force Aspect Ratio", isOn: $isForced)
/// ```
public struct UMUIMiniSwitch: View {
    /// The label text displayed beside the toggle.
    public let title: String
    
    /// Binding to the toggle state.
    @Binding public var isOn: Bool
    
    /// Creates a mini switch.
    /// - Parameters:
    ///   - title: The label text.
    ///   - isOn: Binding to the boolean state.
    public init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }
    
    public var body: some View {
        Toggle(title, isOn: $isOn)
            .font(.caption)
            .controlSize(.mini)
            .toggleStyle(.switch)
    }
}
