//
//  UMUICheckerboard.swift
//  UMUIControls
//
//  A canvas-based checkerboard pattern view, typically used to indicate transparency.
//

import SwiftUI

/// Sizing modes for UMUICheckerboard.
public enum UMUICheckerboardSize: Sendable, Equatable {
    case normal
    case small
}

/// A view that draws a checkerboard pattern, useful for representing transparent backgrounds.
///
/// Usage:
/// ```swift
/// UMUICheckerboard(size: .normal)
/// ```
public struct UMUICheckerboard: View {
    /// The sizing mode of the checkerboard.
    public let size: UMUICheckerboardSize
    
    /// Optional custom square size to override standard sizing.
    public let customSquareSize: CGFloat?
    
    /// The primary color of the checkerboard.
    public let color1: Color
    
    /// The secondary color of the checkerboard.
    public let color2: Color
    
    /// Creates a checkerboard view.
    /// - Parameters:
    ///   - size: Sizing mode (default is `.normal`).
    ///   - squareSize: Optional custom square size (overrides the sizing mode).
    ///   - color1: First color (default white).
    ///   - color2: Second color (default light gray).
    public init(
        size: UMUICheckerboardSize = .small,
        squareSize: CGFloat? = nil,
        color1: Color = .white,
        color2: Color = .gray.opacity(0.3)
    ) {
        self.size = size
        self.customSquareSize = squareSize
        self.color1 = color1
        self.color2 = color2
    }
    
    private var resolvedSquareSize: CGFloat {
        if let customSquareSize = customSquareSize {
            return customSquareSize
        }
        return size == .normal ? 20 : 10
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let sqSize = resolvedSquareSize
                let rows = Int(ceil(size.height / sqSize))
                let cols = Int(ceil(size.width / sqSize))
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let rect = CGRect(
                            x: CGFloat(col) * sqSize,
                            y: CGFloat(row) * sqSize,
                            width: sqSize,
                            height: sqSize
                        )
                        
                        let isEven = (row + col) % 2 == 0
                        context.fill(Path(rect), with: .color(isEven ? color2 : color1))
                    }
                }
            }
        }
    }
}
