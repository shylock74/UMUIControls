//
//  UMUISmallSwitch.swift
//  UMUIControls
//
//  A small toggle switch with a caption-sized label.
//  Uses `.controlSize(.small)` for a compact but readable toggle.
//

import SwiftUI

/// A small-sized toggle with an inline label.
///
/// Usage:
/// ```swift
/// UMUISmallSwitch("Custom Bitrate", isOn: $enableBitrate)
/// ```
public struct UMUISmallSwitch: View {
    /// The label text displayed beside the toggle.
    public let title: String
    
    /// Binding to the toggle state.
    @Binding public var isOn: Bool
    
    /// Creates a small switch.
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
            .controlSize(.small)
            .toggleStyle(.switch)
    }
}
