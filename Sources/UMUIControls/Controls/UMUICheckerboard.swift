//
//  UMUICheckerboard.swift
//  UMUIControls
//
//  A canvas-based checkerboard pattern view, typically used to indicate transparency.
//

import SwiftUI

/// A view that draws a checkerboard pattern, useful for representing transparent backgrounds.
///
/// Usage:
/// ```swift
/// UMUICheckerboard(squareSize: 20, color1: .white, color2: .gray.opacity(0.3))
/// ```
public struct UMUICheckerboard: View {
    /// The size of each square in the checkerboard pattern.
    public let squareSize: CGFloat
    
    /// The primary color of the checkerboard.
    public let color1: Color
    
    /// The secondary color of the checkerboard.
    public let color2: Color
    
    /// Creates a checkerboard view.
    /// - Parameters:
    ///   - squareSize: Size of the squares (default 20).
    ///   - color1: First color (default white).
    ///   - color2: Second color (default light gray).
    public init(
        squareSize: CGFloat = 20,
        color1: Color = .white,
        color2: Color = .gray.opacity(0.3)
    ) {
        self.squareSize = squareSize
        self.color1 = color1
        self.color2 = color2
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let rows = Int(ceil(size.height / squareSize))
                let cols = Int(ceil(size.width / squareSize))
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let rect = CGRect(
                            x: CGFloat(col) * squareSize,
                            y: CGFloat(row) * squareSize,
                            width: squareSize,
                            height: squareSize
                        )
                        
                        let isEven = (row + col) % 2 == 0
                        context.fill(Path(rect), with: .color(isEven ? color2 : color1))
                    }
                }
            }
        }
    }
}
