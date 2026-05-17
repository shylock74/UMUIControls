//
//  UMUIAngleControl.swift
//  UMUIControls
//
//  A circular dial control for editing angle values.
//  Supports Command-key snapping at 15° intervals.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

/// Sizing modes for UMUIAngleControl.
public enum UMUIAngleControlSize: Sendable, Equatable {
    case normal
    case small
}

/// A circular dial control for visually editing an angle value.
///
/// The dial displays tick marks at 15°/45°/90° intervals and a draggable knob
/// colored with the app's `accentColor`. Hold Command while dragging to snap
/// to 15° increments.
///
/// Usage:
/// ```swift
/// UMUIAngleControl(angle: $rotation, size: .normal)
/// ```
public struct UMUIAngleControl: View {
    /// The angle in degrees, typically in the range -180...180.
    @Binding public var angle: Double
    
    /// The sizing mode of the angle control.
    public let size: UMUIAngleControlSize
    
    /// A custom diameter override for backward compatibility.
    public let customDiameter: CGFloat?
    
    /// Creates a new angle control.
    /// - Parameters:
    ///   - angle: Binding to the angle value in degrees.
    ///   - size: Sizing mode (default is `.normal`).
    ///   - customDiameter: Optional diameter override in points.
    public init(angle: Binding<Double>, size: UMUIAngleControlSize = .small, customDiameter: CGFloat? = nil) {
        self._angle = angle
        self.size = size
        self.customDiameter = customDiameter
    }
    
    private var diameter: CGFloat {
        if let customDiameter = customDiameter {
            return customDiameter
        }
        return size == .normal ? 80 : 50
    }
    
    private var indicatorSize: CGFloat {
        return size == .normal ? 12 : 8
    }
    
    public var body: some View {
        VStack {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: size == .normal ? 4 : 2.5)
                    .frame(width: diameter, height: diameter)
                
                // Tick marks (24 ticks at 15° intervals)
                ForEach(0..<24) { i in
                    let tickHeight: CGFloat = {
                        if size == .normal {
                            return i % 6 == 0 ? 8 : (i % 3 == 0 ? 6 : 4)
                        } else {
                            return i % 6 == 0 ? 5 : (i % 3 == 0 ? 4 : 2.5)
                        }
                    }()
                    
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: size == .normal ? 2 : 1.2, height: tickHeight)
                        .offset(y: -diameter / 2 + (size == .normal ? 6 : 4))
                        .rotationEffect(.degrees(Double(i) * 15))
                }
                
                // Knob / indicator
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: indicatorSize, height: indicatorSize)
                    .offset(y: -diameter / 2)
                    .rotationEffect(.degrees(angle))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let vector = CGVector(
                                    dx: value.location.x - diameter / 2,
                                    dy: value.location.y - diameter / 2
                                )
                                
                                // Calculate angle from center (0° = top)
                                var newAngle = atan2(vector.dy, vector.dx) * 180 / .pi + 90
                                if newAngle < 0 { newAngle += 360 }
                                
                                // Command-key snapping at 15° intervals
                                #if canImport(AppKit)
                                if NSEvent.modifierFlags.contains(.command) {
                                    let snapStep: Double = 15
                                    newAngle = (newAngle / snapStep).rounded() * snapStep
                                }
                                #endif
                                
                                // Normalize to 0...360
                                if newAngle >= 360 { newAngle -= 360 }
                                
                                // Convert to -180...180 range
                                if newAngle > 180 { newAngle -= 360 }
                                
                                self.angle = newAngle
                            }
                    )
            }
            .frame(width: diameter, height: diameter)
        }
    }
}
