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

/// A circular dial control for visually editing an angle value.
///
/// The dial displays tick marks at 15°/45°/90° intervals and a draggable knob
/// colored with the app's `accentColor`. Hold Command while dragging to snap
/// to 15° increments.
///
/// Usage:
/// ```swift
/// UMUIAngleControl(angle: $rotation, size: 80)
/// ```
public struct UMUIAngleControl: View {
    /// The angle in degrees, typically in the range -180...180.
    @Binding public var angle: Double
    
    /// The diameter of the dial circle.
    public var size: CGFloat
    
    /// Creates a new angle control.
    /// - Parameters:
    ///   - angle: Binding to the angle value in degrees.
    ///   - size: The diameter of the control (default 80).
    public init(angle: Binding<Double>, size: CGFloat = 80) {
        self._angle = angle
        self.size = size
    }
    
    public var body: some View {
        VStack {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 4)
                    .frame(width: size, height: size)
                
                // Tick marks (24 ticks at 15° intervals)
                ForEach(0..<24) { i in
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 2, height: i % 6 == 0 ? 8 : (i % 3 == 0 ? 6 : 4))
                        .offset(y: -size / 2 + 6)
                        .rotationEffect(.degrees(Double(i) * 15))
                }
                
                // Knob / indicator
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 12, height: 12)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(angle))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let vector = CGVector(
                                    dx: value.location.x - size / 2,
                                    dy: value.location.y - size / 2
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
            .frame(width: size, height: size)
        }
    }
}
