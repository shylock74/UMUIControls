//
//  UMUIRadioButton.swift
//  UMUIControls
//
//  A custom radio button control using SF Symbols.
//  Displays a filled circle when selected and an empty circle when unselected.
//

import SwiftUI

/// A radio button control that displays a filled or empty circle.
///
/// Uses `Color.accentColor` for the selected state.
///
/// Usage:
/// ```swift
/// UMUIRadioButton(selected: currentSelection == .option1) {
///     currentSelection = .option1
/// }
/// ```
public struct UMUIRadioButton: View {
    /// Whether the radio button is in its selected state.
    public let selected: Bool
    
    /// The action to perform when tapped.
    public let action: () -> Void
    
    /// Creates a new radio button.
    /// - Parameters:
    ///   - selected: Whether this button appears selected.
    ///   - action: Closure invoked on tap.
    public init(selected: Bool, action: @escaping () -> Void) {
        self.selected = selected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                .foregroundStyle(selected ? Color.accentColor : .gray)
        }
        .buttonStyle(.plain)
    }
}
