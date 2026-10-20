//
//  UMUIResizableDivider.swift
//  UMUIControls
//
//  A draggable divider that resizes one pane through a bound length, plus
//  two-pane stacks built on it. Unlike the native split views, the size of
//  the resizable pane is owned by the caller, so it can be stored and restored.
//

import SwiftUI

/// Edge of a two-pane stack where the resizable pane sits.
@available(macOS 11.0, *)
public enum UMUIResizableEdge: Sendable, Equatable {
    /// Resizable pane first (left in an `HStack`, top in a `VStack`).
    case leading

    /// Resizable pane last (right in an `HStack`, bottom in a `VStack`).
    case trailing
}

/// A thin line the user drags to change `size`, clamped to `range`.
///
/// `edge` says which side of the divider the resizable pane is on, so dragging toward
/// the pane shrinks it. The divider has a wider hit area than its 1 pt line.
///
/// Usage:
/// ```swift
/// UMUIResizableDivider(axis: .vertical, size: $timelineHeight, range: 120...480, edge: .trailing)
/// ```
@available(macOS 11.0, *)
public struct UMUIResizableDivider: View {
    /// `.vertical` splits left/right (a vertical line); `.horizontal` splits top/bottom.
    public let axis: Axis

    @Binding public var size: CGFloat
    public let range: ClosedRange<CGFloat>
    public let edge: UMUIResizableEdge

    @State private var sizeAtDragStart: CGFloat?
    @State private var isHovering = false

    public init(axis: Axis, size: Binding<CGFloat>, range: ClosedRange<CGFloat>, edge: UMUIResizableEdge = .trailing) {
        self.axis = axis
        self._size = size
        self.range = range
        self.edge = edge
    }

    /// New size for a drag of `translation` points along the divider's axis.
    public static func resized(from start: CGFloat, translation: CGFloat, edge: UMUIResizableEdge, range: ClosedRange<CGFloat>) -> CGFloat {
        let proposed = edge == .leading ? start + translation : start - translation
        return Swift.min(Swift.max(proposed, range.lowerBound), range.upperBound)
    }

    public var body: some View {
        let isVerticalLine = axis == .vertical
        Rectangle()
            .fill(Color.secondary.opacity(isHovering || sizeAtDragStart != nil ? 0.5 : 0.2))
            .frame(width: isVerticalLine ? 1 : nil, height: isVerticalLine ? nil : 1)
            .padding(isVerticalLine ? .horizontal : .vertical, 3)
            .contentShape(Rectangle())
            .onHover { inside in
                isHovering = inside
                if inside {
                    (isVerticalLine ? NSCursor.resizeLeftRight : NSCursor.resizeUpDown).push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .global)
                    .onChanged { value in
                        let start = sizeAtDragStart ?? size
                        sizeAtDragStart = start
                        let translation = isVerticalLine ? value.translation.width : value.translation.height
                        size = Self.resized(from: start, translation: translation, edge: edge, range: range)
                    }
                    .onEnded { _ in sizeAtDragStart = nil }
            )
    }
}

/// Two panes side by side; the one on `edge` has the bound width, the other takes the rest.
@available(macOS 11.0, *)
public struct UMUIResizableHStack<Primary: View, Secondary: View>: View {
    @Binding public var secondaryWidth: CGFloat
    public let range: ClosedRange<CGFloat>
    public let edge: UMUIResizableEdge
    public let primary: Primary
    public let secondary: Secondary

    /// - Parameters:
    ///   - secondaryWidth: Width of the resizable pane.
    ///   - edge: `.trailing` puts the resizable pane on the right, `.leading` on the left.
    public init(
        secondaryWidth: Binding<CGFloat>,
        range: ClosedRange<CGFloat> = 160...600,
        edge: UMUIResizableEdge = .trailing,
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self._secondaryWidth = secondaryWidth
        self.range = range
        self.edge = edge
        self.primary = primary()
        self.secondary = secondary()
    }

    public var body: some View {
        HStack(spacing: 0) {
            if edge == .leading {
                secondary.frame(width: secondaryWidth).frame(maxHeight: .infinity)
                UMUIResizableDivider(axis: .vertical, size: $secondaryWidth, range: range, edge: .leading)
                primary.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                primary.frame(maxWidth: .infinity, maxHeight: .infinity)
                UMUIResizableDivider(axis: .vertical, size: $secondaryWidth, range: range, edge: .trailing)
                secondary.frame(width: secondaryWidth).frame(maxHeight: .infinity)
            }
        }
    }
}

/// Two panes stacked; the one on `edge` has the bound height, the other takes the rest.
@available(macOS 11.0, *)
public struct UMUIResizableVStack<Primary: View, Secondary: View>: View {
    @Binding public var secondaryHeight: CGFloat
    public let range: ClosedRange<CGFloat>
    public let edge: UMUIResizableEdge
    public let primary: Primary
    public let secondary: Secondary

    /// - Parameters:
    ///   - secondaryHeight: Height of the resizable pane.
    ///   - edge: `.trailing` puts the resizable pane at the bottom, `.leading` at the top.
    public init(
        secondaryHeight: Binding<CGFloat>,
        range: ClosedRange<CGFloat> = 120...600,
        edge: UMUIResizableEdge = .trailing,
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self._secondaryHeight = secondaryHeight
        self.range = range
        self.edge = edge
        self.primary = primary()
        self.secondary = secondary()
    }

    public var body: some View {
        VStack(spacing: 0) {
            if edge == .leading {
                secondary.frame(height: secondaryHeight).frame(maxWidth: .infinity)
                UMUIResizableDivider(axis: .horizontal, size: $secondaryHeight, range: range, edge: .leading)
                primary.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                primary.frame(maxWidth: .infinity, maxHeight: .infinity)
                UMUIResizableDivider(axis: .horizontal, size: $secondaryHeight, range: range, edge: .trailing)
                secondary.frame(height: secondaryHeight).frame(maxWidth: .infinity)
            }
        }
    }
}
