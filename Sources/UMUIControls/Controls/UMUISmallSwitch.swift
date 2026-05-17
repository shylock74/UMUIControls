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
/// UMUISmallSwitch("Custom Bitrate", isOn: $enableBitrate, size: .normal)
/// ```
public struct UMUISmallSwitch: View {
    /// The label text displayed beside the toggle.
    public let title: String
    
    /// Binding to the toggle state.
    @Binding public var isOn: Bool
    
    /// The sizing mode of the switch.
    public let size: UMUISwitchSize
    
    /// Creates a small switch.
    /// - Parameters:
    ///   - title: The label text.
    ///   - isOn: Binding to the boolean state.
    ///   - size: Sizing mode (default is `.normal`).
    public init(_ title: String, isOn: Binding<Bool>, size: UMUISwitchSize = .small) {
        self.title = title
        self._isOn = isOn
        self.size = size
    }
    
    public var body: some View {
        Toggle(title, isOn: $isOn)
            .font(size == .normal ? .body : .caption)
            .controlSize(size == .normal ? .regular : .small)
            .toggleStyle(.switch)
    }
}
