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
            let sqSize = resolvedSquareSize
            let rows = Int(ceil(geometry.size.height / sqSize))
            let cols = Int(ceil(geometry.size.width / sqSize))
            
            ZStack {
                color1
                CheckerboardShape(squareSize: sqSize, rows: rows, cols: cols)
                    .fill(color2)
            }
        }
    }
}

/// A highly-efficient Shape that calculates and draws only the secondary tiles in a checkerboard pattern.
struct CheckerboardShape: Shape {
    let squareSize: CGFloat
    let rows: Int
    let cols: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for row in 0..<rows {
            for col in 0..<cols {
                // Draw secondary squares at even positions
                if (row + col) % 2 == 0 {
                    let tileRect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    path.addRect(tileRect)
                }
            }
        }
        
        return path
    }
}
