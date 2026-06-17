//
//  UMUIRadioButton.swift
//  UMUIControls
//
//  A custom radio button control using SF Symbols.
//  Displays a filled circle when selected and an empty circle when unselected.
//

import SwiftUI

/// Sizing modes for UMUIRadioButton.
@available(macOS 11.0, *)
public enum UMUIRadioButtonSize: Sendable, Equatable {
    case normal
    case small
}

/// A radio button control that displays a filled or empty circle.
///
/// Uses `Color.accentColor` for the selected state.
///
/// > [!IMPORTANT]
/// > **Memory Safety:** If the `action` closure captures reference types (like view controllers
/// > or view models), ensure you capture them weakly (e.g. `[weak self]`) to prevent strong reference cycles and memory leaks.
///
/// Usage:
/// ```swift
/// UMUIRadioButton(selected: currentSelection == .option1, size: .normal) { [weak self] in
///     self?.currentSelection = .option1
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIRadioButton: View {
    /// Whether the radio button is in its selected state.
    public let selected: Bool
    
    /// The sizing mode of the radio button.
    public let size: UMUIRadioButtonSize
    
    /// The action to perform when tapped.
    public let action: () -> Void
    
    /// Creates a new radio button.
    /// - Parameters:
    ///   - selected: Whether this button appears selected.
    ///   - size: Sizing mode (default is `.normal`).
    ///   - action: Closure invoked on tap. Capture reference types weakly to prevent leaks.
    public init(
        selected: Bool,
        size: UMUIRadioButtonSize = .small,
        action: @escaping () -> Void
    ) {
        self.selected = selected
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                .font(size == .normal ? .body : .caption)
                .foregroundColor(selected ? Color.accentColor : .gray)
        }
        .buttonStyle(.plain)
    }
}
