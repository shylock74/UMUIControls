//
//  UMUIKnobControl.swift
//  UMUIControls
//
//  A premium, visual rotary knob control designed for audio and creative parameters.
//  Supports professional vertical drag gestures (up increases, down decreases),
//  smooth radial arc fill tracking, hover status tooltips, and double-click to reset.
//

import SwiftUI

/// A professional visual rotary knob control for editing Double values inside a range.
///
/// Operates on professional vertical drag gestures rather than circular rotation,
/// guaranteeing extreme precision even in highly dense inspector panels.
/// Supports double-click to reset to a default value.
///
/// Usage:
/// ```swift
/// UMUIKnobControl(label: "Gain", value: $gain, range: 0...10, defaultValue: 5.0)
/// ```
public struct UMUIKnobControl: View {
    /// The optional label displayed alongside the knob.
    public let label: String?
    
    /// The underlying binding value updated on drag.
    @Binding public var value: Double
    
    /// The valid range for the value.
    public let range: ClosedRange<Double>
    
    /// Optional default value to reset to when double-clicked.
    public let defaultValue: Double?
    
    /// The size (diameter) of the rotary knob dial (default is 40).
    public let size: CGFloat
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    // MARK: - Internal States
    
    @State private var isDragging: Bool = false
    @State private var startValue: Double = 0.0
    @State private var isHovered: Bool = false
    
    /// Creates a new rotary knob control.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - value: Binding to the numeric value.
    ///   - range: The valid range (default is `0...1`).
    ///   - defaultValue: Optional value to reset to on double-click (default is `nil`).
    ///   - size: Diameter of the dial circle (default is `40`).
    ///   - labelWidth: Width reserved for the label (default is `80`).
    public init(
        label: String? = nil,
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...1,
        defaultValue: Double? = nil,
        size: CGFloat = 40,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.defaultValue = defaultValue
        self.size = size
        self.labelWidth = labelWidth
    }
    
    private var fraction: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0.0 }
        return min(max((value - range.lowerBound) / span, 0.0), 1.0)
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
            // Optional Label
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }
            
            // Interactive Knob Component
            ZStack {
                // Background dial track (subtle gray arc)
                KnobTrackShape()
                    .stroke(
                        Color.secondary.opacity(0.15),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                
                // Foreground active track (accent colored arc)
                KnobActiveShape(fraction: fraction)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .animation(.easeOut(duration: 0.1), value: value)
                
                // Rotatable inner knob body
                Circle()
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .frame(width: size - 8, height: size - 8)
                    .shadow(color: .black.opacity(isDragging ? 0.25 : 0.15), radius: isDragging ? 3 : 1.5, y: 1)
                    .overlay(
                        // Inner knob border
                        Circle()
                            .stroke(isHovered ? Color.accentColor.opacity(0.3) : Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .overlay(
                        // Value indicator tick line pointing to the current angle
                        RoundedRectangle(cornerRadius: 1)
                            .fill(isDragging ? Color.accentColor : Color.primary.opacity(0.8))
                            .frame(width: 2.0, height: (size - 8) * 0.3)
                            .offset(y: -(size - 8) * 0.3)
                    )
                    // Rotate the dial by matching fractional degrees (-140° to 140°)
                    .rotationEffect(.degrees(-140.0 + fraction * 280.0))
                    .animation(.easeOut(duration: 0.1), value: value)
            }
            .frame(width: size + 6, height: size + 6)
            .contentShape(Circle())
            // Hover state and dragging popover tooltip
            .onHover { hovering in
                isHovered = hovering
            }
            .overlay(
                // Interactive floating value tooltip overlay
                Group {
                    if isHovered || isDragging {
                        Text(String(format: "%.1f", value))
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 2, y: 1.5)
                            .offset(y: -size - 10)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }
                .animation(.spring(response: 0.15, dampingFraction: 0.75), value: isHovered || isDragging)
            )
            // Gesture interactions
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            startValue = value
                        }
                        
                        // Drag up increases, drag down decreases
                        let deltaY = -gesture.translation.height
                        // Professional precision multiplier
                        let sensitivity = 0.0035
                        let rangeSpan = range.upperBound - range.lowerBound
                        let deltaValue = Double(deltaY) * sensitivity * rangeSpan
                        let newValue = min(max(startValue + deltaValue, range.lowerBound), range.upperBound)
                        
                        if value != newValue {
                            value = newValue
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            // Double-click to reset back to defaultValue
            .onTapGesture(count: 2) {
                if let defaultValue = defaultValue {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                        value = defaultValue
                    }
                }
            }
        }
    }
}

// MARK: - Radial Arc Shapes

/// Path rendering the background boundary bounds from 130° to 410° (clockwise).
private struct KnobTrackShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(130),
            endAngle: .degrees(410),
            clockwise: false
        )
        return path
    }
}

/// Path rendering the active accent colored level dial fill.
private struct KnobActiveShape: Shape {
    let fraction: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(130),
            endAngle: .degrees(130 + fraction * 280),
            clockwise: false
        )
        return path
    }
}

// MARK: - Previews

#if DEBUG
struct UMUIKnobControl_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var volume: Double = 3.5
        @State private var panning: Double = 0.0
        @State private var highPass: Double = 120.0
        
        var body: some View {
            VStack(spacing: 25) {
                Text("UMUIKnobControl Previews")
                    .font(.headline)
                
                Text("Drag vertically up/down to adjust values. Double-click to reset.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20) {
                    UMUIKnobControl(
                        label: "Volume (dB)",
                        value: $volume,
                        range: 0...10,
                        defaultValue: 5.0,
                        size: 40
                    )
                    
                    UMUIKnobControl(
                        label: "Pan (L/R)",
                        value: $panning,
                        range: -1...1,
                        defaultValue: 0.0,
                        size: 35
                    )
                    
                    UMUIKnobControl(
                        label: "Cutoff (Hz)",
                        value: $highPass,
                        range: 20...20000,
                        defaultValue: 120.0,
                        size: 45
                    )
                }
                
                Divider()
                
                // Value monitors
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Volume Value:")
                            .font(.caption2).bold()
                        Spacer()
                        Text(String(format: "%.3f dB", volume))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(Color.accentColor)
                    }
                    HStack {
                        Text("Panning Value:")
                            .font(.caption2).bold()
                        Spacer()
                        Text(String(format: "%.3f", panning))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .padding(30)
            .frame(width: 380)
        }
    }
    
    static var previews: some View {
        TestWrapper()
    }
}
#endif
