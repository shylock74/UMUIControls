//
//  UMLeftObjectView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 25/08/21.
//

import SwiftUI

/// A layout view modifier that left-aligns content inside a horizontal container.
public struct UMLeftObjectView: ViewModifier {
    public var width: CGFloat? = nil
    
    public init(width: CGFloat? = nil) {
        self.width = width
    }
    
    @ViewBuilder
    func leftedContent(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
        .frame(width: width)
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if let width = width {
            leftedContent(content: content)
                .frame(width: width)
        } else {
            leftedContent(content: content)
        }
    }
}

/// A layout view modifier that top-aligns content inside a vertical container.
public struct UMTopObjectView: ViewModifier {
    public init() {}
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        VStack {
            content
            Spacer(minLength: 0)
        }
    }
}

/// A layout view modifier that center-aligns content horizontally.
public struct UMCenterObjectView: ViewModifier {
    public var width: CGFloat? = nil
    
    public init(width: CGFloat? = nil) {
        self.width = width
    }
    
    @ViewBuilder
    func centeredContent(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            content
            Spacer(minLength: 0)
        }
        .frame(width: width)
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if let width = width {
            centeredContent(content: content)
                .frame(width: width)
        } else {
            centeredContent(content: content)
        }
    }
}

/// A layout view modifier that centers content vertically.
public struct UMZCenterObjectView: ViewModifier {
    public init() {}
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        VStack {
            Spacer(minLength: 0)
            content
            Spacer(minLength: 0)
        }
    }
}

public extension View {
    /// Left-aligns this view inside its parent container.
    func leftObject(_ width: CGFloat? = nil) -> some View {
        self.modifier(UMLeftObjectView(width: width))
    }
    
    /// Horizontally centers this view inside its parent container.
    func umCentered() -> some View {
        self.modifier(UMCenterObjectView())
    }
    
    /// Vertically centers this view inside its parent container.
    func umZCentered() -> some View {
        self.modifier(UMZCenterObjectView())
    }
}
