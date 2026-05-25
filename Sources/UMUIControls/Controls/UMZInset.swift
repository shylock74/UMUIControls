//
//  UMZInset.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 25/09/21.
//

import SwiftUI

public struct UMZInset: ViewModifier {
    
    public enum Corner {
        case upperLeft
        case upperRight
        case lowerLeft
        case lowerRight
        case left
        case bottom
        case top
        
        func left() -> Bool {
            return self == .upperLeft || self == .lowerLeft || self == .left
        }
        
        func right() -> Bool {
            return self == .upperRight || self == .lowerRight
        }
        
        func upper() -> Bool {
            return self == .upperLeft || self == .upperRight || self == .top
        }
        
        func lower() -> Bool {
            return self == .lowerLeft || self == .lowerRight || self == .bottom
        }
    }
    
    public var corner: Corner = .upperLeft
    
    @ViewBuilder
    func inset(content: Content) -> some View {
        HStack(spacing: 2) {
            if corner.right() {
                Spacer(minLength: 0)
            }
            VStack {
                if corner.lower() {
                    Spacer(minLength: 0)
                }
                content
                if corner.upper() {
                    Spacer(minLength: 0)
                }
            }
            if corner.left() {
                Spacer(minLength: 0)
            }
        }
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        inset(content: content)
    }
}

public extension View {
    func umZInset(corner: UMZInset.Corner = .upperLeft) -> some View {
        self.modifier(UMZInset(corner: corner))
    }
    
    func umZInset(_ corner: UMZInset.Corner = .upperLeft) -> some View {
        self.modifier(UMZInset(corner: corner))
    }
}
