//
//  UMUIPositionGrid.swift
//  UMUIControls
//
//  A 3×3 grid of position buttons for selecting an anchor point.
//  Generalised version of PositionButton from the Overlay app.
//

import SwiftUI

/// Represents one of nine anchor positions in a 3×3 grid.
public enum UMUIPosition: String, CaseIterable, Identifiable, Codable, Sendable {
    case topLeft, top, topRight
    case left, center, right
    case bottomLeft, bottom, bottomRight
    
    public var id: String { rawValue }
    
    /// The SF Symbol name for the directional arrow (or circle for center).
    public var iconName: String {
        switch self {
        case .topLeft:     return "arrow.up.left"
        case .top:         return "arrow.up"
        case .topRight:    return "arrow.up.right"
        case .left:        return "arrow.left"
        case .center:      return "circle"
        case .right:       return "arrow.right"
        case .bottomLeft:  return "arrow.down.left"
        case .bottom:      return "arrow.down"
        case .bottomRight: return "arrow.down.right"
        }
    }
    
    /// A human-readable label for accessibility and tooltips.
    public var label: String {
        switch self {
        case .topLeft:     return "Top Left"
        case .top:         return "Top Center"
        case .topRight:    return "Top Right"
        case .left:        return "Center Left"
        case .center:      return "Center"
        case .right:       return "Center Right"
        case .bottomLeft:  return "Bottom Left"
        case .bottom:      return "Bottom Center"
        case .bottomRight: return "Bottom Right"
        }
    }
}

/// A single position button within the grid.
///
/// Highlighted with `Color.accentColor` when its position matches the current selection.
public struct UMUIPositionButton: View {
    /// The position this button represents.
    public let position: UMUIPosition
    
    /// Binding to the currently selected position.
    @Binding public var current: UMUIPosition
    
    /// Optional callback invoked after the position changes.
    public var action: (() -> Void)?
    
    /// Creates a position button.
    /// - Parameters:
    ///   - position: The position this button represents.
    ///   - current: Binding to the current selection.
    ///   - action: Optional closure called after selection.
    public init(position: UMUIPosition, current: Binding<UMUIPosition>, action: (() -> Void)? = nil) {
        self.position = position
        self._current = current
        self.action = action
    }
    
    public var body: some View {
        Button {
            current = position
            action?()
        } label: {
            Label(position.label, systemImage: position.iconName)
                .font(.system(size: 10, weight: .bold))
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.bordered)
        .labelStyle(.iconOnly)
        .tint(current == position ? .accentColor : .secondary)
        .controlSize(.mini)
    }
}

/// A 3×3 grid of position buttons for anchor selection.
///
/// > [!IMPORTANT]
/// > **Memory Safety:** If the `action` closure captures reference types (like view controllers
/// > or view models), ensure you capture them weakly (e.g. `[weak self]`) to prevent strong reference cycles and memory leaks.
///
/// Usage:
/// ```swift
/// UMUIPositionGrid(selection: $position) { [weak self] in
///     self?.offset = .zero
/// }
/// ```
public struct UMUIPositionGrid: View {
    /// Binding to the currently selected position.
    @Binding public var selection: UMUIPosition
    
    /// Optional callback invoked after any position button is tapped.
    public var action: (() -> Void)?
    
    /// Creates a position grid.
    /// - Parameters:
    ///   - selection: Binding to the selected position.
    ///   - action: Optional closure called on selection change.
    public init(selection: Binding<UMUIPosition>, action: (() -> Void)? = nil) {
        self._selection = selection
        self.action = action
    }
    
    public var body: some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            GridRow {
                UMUIPositionButton(position: .topLeft, current: $selection, action: action)
                UMUIPositionButton(position: .top, current: $selection, action: action)
                UMUIPositionButton(position: .topRight, current: $selection, action: action)
            }
            GridRow {
                UMUIPositionButton(position: .left, current: $selection, action: action)
                UMUIPositionButton(position: .center, current: $selection, action: action)
                UMUIPositionButton(position: .right, current: $selection, action: action)
            }
            GridRow {
                UMUIPositionButton(position: .bottomLeft, current: $selection, action: action)
                UMUIPositionButton(position: .bottom, current: $selection, action: action)
                UMUIPositionButton(position: .bottomRight, current: $selection, action: action)
            }
        }
    }
}
