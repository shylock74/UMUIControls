//
//  UMCenter.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 01/10/21.
//

import SwiftUI

/// A centering utility view modifier that centers content horizontally, vertically, or both.
public struct UMCenter: ViewModifier {
    public enum Direction {
        case horizontally
        case vertically
        case both
    }
    
    public var direction: Direction = .horizontally
    
    public init(direction: Direction = .horizontally) {
        self.direction = direction
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if direction == .horizontally {
            content
                .frame(maxWidth: .infinity, alignment: .center)
        } else if direction == .vertically {
            content
                .frame(maxHeight: .infinity, alignment: .center)
        } else {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

public extension View {
    /// Center a view horizontally, vertically, or in both directions.
    func umCenter(_ direction: UMCenter.Direction = .horizontally) -> some View {
        self.modifier(UMCenter(direction: direction))
    }
}
