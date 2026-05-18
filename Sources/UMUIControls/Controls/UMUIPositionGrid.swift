//
//  UMUIPositionGrid.swift
//  UMUIControls
//
//  A 3×3 grid of position buttons for selecting an anchor point.
//  Generalised version of PositionButton from the Overlay app.
//

import SwiftUI

/// Sizing modes for UMUIPositionGrid.
public enum UMUIPositionGridSize: Sendable, Equatable {
    case normal
    case small
}

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
    
    /// Sizing mode of the button.
    public let size: UMUIPositionGridSize
    
    /// Optional callback invoked after the position changes.
    public var action: (() -> Void)?
    
    /// Creates a position button.
    /// - Parameters:
    ///   - position: The position this button represents.
    ///   - current: Binding to the current selection.
    ///   - size: Sizing mode of the button (default is `.normal`).
    ///   - action: Optional closure called after selection.
    public init(
        position: UMUIPosition,
        current: Binding<UMUIPosition>,
        size: UMUIPositionGridSize = .small,
        action: (() -> Void)? = nil
    ) {
        self.position = position
        self._current = current
        self.size = size
        self.action = action
    }
    
    private var buttonDimension: CGFloat {
        return size == .normal ? 26 : 20
    }
    
    private var fontSize: CGFloat {
        return size == .normal ? 12 : 10
    }
    
    public var body: some View {
        Button {
            current = position
            action?()
        } label: {
            Label(position.label, systemImage: position.iconName)
                .font(.system(size: fontSize, weight: .bold))
                .frame(width: buttonDimension, height: buttonDimension)
        }
        .buttonStyle(.bordered)
        .labelStyle(.iconOnly)
        .tint(current == position ? .accentColor : .secondary)
        .controlSize(size == .normal ? .small : .mini)
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
/// UMUIPositionGrid(selection: $position, size: .normal) { [weak self] in
///     self?.offset = .zero
/// }
/// ```
public struct UMUIPositionGrid: View {
    /// Binding to the currently selected position.
    @Binding public var selection: UMUIPosition
    
    /// The sizing mode of the grid.
    public let size: UMUIPositionGridSize
    
    /// Optional callback invoked after any position button is tapped.
    public var action: (() -> Void)?
    
    /// Creates a position grid.
    /// - Parameters:
    ///   - selection: Binding to the selected position.
    ///   - size: Sizing mode (default is `.normal`).
    ///   - action: Optional closure called on selection change.
    public init(
        selection: Binding<UMUIPosition>,
        size: UMUIPositionGridSize = .small,
        action: (() -> Void)? = nil
    ) {
        self._selection = selection
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                UMUIPositionButton(position: .topLeft, current: $selection, size: size, action: action)
                UMUIPositionButton(position: .top, current: $selection, size: size, action: action)
                UMUIPositionButton(position: .topRight, current: $selection, size: size, action: action)
            }
            HStack(spacing: 2) {
                UMUIPositionButton(position: .left, current: $selection, size: size, action: action)
                UMUIPositionButton(position: .center, current: $selection, size: size, action: action)
                UMUIPositionButton(position: .right, current: $selection, size: size, action: action)
            }
            HStack(spacing: 2) {
                UMUIPositionButton(position: .bottomLeft, current: $selection, size: size, action: action)
                UMUIPositionButton(position: .bottom, current: $selection, size: size, action: action)
                UMUIPositionButton(position: .bottomRight, current: $selection, size: size, action: action)
            }
        }
    }
}
