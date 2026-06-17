//
//  UMUIVerticalSlider.swift
//  UMUIControls
//
//  A premium, professional visual vertical slider designed for creative panels
//  and audio mixing faders. Features side tick-marks, a mixing desk horizontal
//  pill thumb fader, drag-to-track gestures, and inverted scale options.
//

import SwiftUI

/// Sizing modes for UMUIVerticalSlider.
@available(macOS 11.0, *)
public enum UMUIVerticalSliderSize: Sendable, Equatable {
    case normal
    case small
}

/// A professional-grade vertical slider/fader control suitable for mixers, parametric panels, and equalizers.
///
/// Features professional horizontal pill-fader styling, a graduation grid of tick-marks,
/// click-to-snap, and support for inverted orientation (minimum value at bottom or top).
///
/// Usage:
/// ```swift
/// UMUIVerticalSlider(label: "Fader 1", value: $volume, range: -60...12, size: .normal)
/// ```
@available(macOS 11.0, *)
public struct UMUIVerticalSlider: View {
    /// The optional label displayed alongside or above the fader.
    public let label: String?
    
    /// The underlying binding value updated by the fader.
    @Binding public var value: Double
    
    /// The active range bounds for the value.
    public let range: ClosedRange<Double>
    
    /// The vertical height of the fader (optional override).
    public let height: CGFloat?
    
    /// The sizing mode of the fader control.
    public let size: UMUIVerticalSliderSize
    
    /// Whether to invert the scale (default is `false`, meaning minimum is at the bottom).
    public let inverted: Bool
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    // MARK: - Internal States
    
    @State private var isDragging: Bool = false
    @State private var isHovered: Bool = false
    
    /// Creates a new vertical fader control.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - value: Binding to the double value.
    ///   - range: Active bounds (default is `0...1`).
    ///   - height: The vertical height override of the fader (default is `nil` to automatically match size).
    ///   - size: Sizing mode (default is `.normal`).
    ///   - inverted: If `true`, the value increases downwards (default is `false`).
    ///   - labelWidth: Horizontal width reserved for label (default is `80`).
    public init(
        label: String? = nil,
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...1,
        height: CGFloat? = nil,
        size: UMUIVerticalSliderSize = .small,
        inverted: Bool = false,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.height = height
        self.size = size
        self.inverted = inverted
        self.labelWidth = labelWidth
    }
    
    private var resolvedHeight: CGFloat {
        if let height = height { return height }
        return size == .normal ? 150 : 110
    }
    
    private var trackWidth: CGFloat {
        return size == .normal ? 12 : 8
    }
    
    private var thumbWidth: CGFloat {
        return size == .normal ? 24 : 18
    }
    
    private var thumbHeight: CGFloat {
        return size == .normal ? 10 : 6
    }
    
    private var fraction: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0.0 }
        let rawFraction = (value - range.lowerBound) / span
        let clamped = min(max(rawFraction, 0.0), 1.0)
        return clamped
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Optional Label
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(size == .normal ? .body : .caption)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }
            
            // Fader Deck Assembly
            HStack(spacing: 6) {
                let currentHeight = resolvedHeight
                let currentTrackWidth = trackWidth
                let currentThumbWidth = thumbWidth
                let currentThumbHeight = thumbHeight
                
                // Vertical Fader Path Track
                GeometryReader { geometry in
                    let h = geometry.size.height
                    let thumbY: CGFloat = {
                        if inverted {
                            return CGFloat(fraction) * h
                        } else {
                            return (1.0 - CGFloat(fraction)) * h
                        }
                    }()
                    
                    ZStack(alignment: .top) {
                        // Glassy track groove
                        RoundedRectangle(cornerRadius: currentTrackWidth / 2)
                            .fill(Color.secondary.opacity(0.12))
                            .frame(width: currentTrackWidth, height: h)
                            .overlay(
                                RoundedRectangle(cornerRadius: currentTrackWidth / 2)
                                    .stroke(Color.secondary.opacity(0.15), lineWidth: 0.5)
                            )
                        
                        // Active color fill line (sweeps from minimum edge)
                        Group {
                            if inverted {
                                // Sweeps from top (y=0) to thumb
                                RoundedRectangle(cornerRadius: currentTrackWidth / 2)
                                    .fill(Color.accentColor)
                                    .frame(width: currentTrackWidth, height: max(0, thumbY))
                            } else {
                                // Sweeps from bottom (y=h) to thumb
                                RoundedRectangle(cornerRadius: currentTrackWidth / 2)
                                    .fill(Color.accentColor)
                                    .frame(width: currentTrackWidth, height: max(0, h - thumbY))
                                    .offset(y: thumbY)
                            }
                        }
                        
                        // Mixing Desk Horizontal Thumb Fader Handle
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .frame(width: currentThumbWidth, height: currentThumbHeight)
                            .shadow(color: .black.opacity(isDragging ? 0.3 : 0.2), radius: isDragging ? 2.5 : 1.5, y: 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(isHovered || isDragging ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 0.5)
                            )
                            // A middle black mark on the fader
                            .overlay(
                                Rectangle()
                                    .fill(isDragging ? Color.accentColor : Color.secondary.opacity(0.8))
                                    .frame(width: currentThumbWidth - 12, height: 1.5)
                            )
                            .offset(x: -(currentThumbWidth - currentTrackWidth) / 2, y: max(0, min(thumbY - currentThumbHeight / 2, h - currentThumbHeight)))
                            .scaleEffect(isHovered || isDragging ? 1.08 : 1.0)
                    }
                    .contentShape(Rectangle())
                    .onHover { hovering in
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                            isHovered = hovering
                        }
                    }
                    // Handle vertical drag gestures and snapping
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isDragging = true
                                let locationY = gesture.location.y
                                let rawPercent = Double(locationY / h)
                                let percent = min(max(inverted ? rawPercent : 1.0 - rawPercent, 0.0), 1.0)
                                let rangeSpan = range.upperBound - range.lowerBound
                                let newValue = range.lowerBound + percent * rangeSpan
                                
                                if value != newValue {
                                    value = newValue
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                }
                .frame(width: currentThumbWidth + 2, height: currentHeight)
                
                // Graduation Tick-marks (0%, 25%, 50%, 75%, 100%)
                VStack(alignment: .leading, spacing: 0) {
                    let steps = [1.0, 0.75, 0.5, 0.25, 0.0]
                    ForEach(steps, id: \.self) { step in
                        HStack(spacing: 4) {
                            // Small white graduation line
                            Rectangle()
                                .fill(Color.secondary.opacity(0.4))
                                .frame(width: size == .normal ? 6 : 4, height: 1)
                            
                            // Proportional label
                            if step == 1.0 || step == 0.5 || step == 0.0 {
                                let labelValue: Double = {
                                    let span = range.upperBound - range.lowerBound
                                    let actualStep = inverted ? 1.0 - step : step
                                    return range.lowerBound + actualStep * span
                                }()
                                Text(String(format: "%.0f", labelValue))
                                    .font(.system(size: size == .normal ? 8 : 7, weight: .regular, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(height: 1)
                        if step > 0.0 {
                            Spacer(minLength: 0)
                        }
                    }
                }
                .frame(height: currentHeight)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIVerticalSlider_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var gain: Double = 0.0
        @State private var pitch: Double = 50.0
        
        var body: some View {
            VStack(spacing: 25) {
                Text("UMUIVerticalSlider Previews")
                    .font(.headline)
                
                Text("Professional vertical mixing deck faders with tick marks.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 35) {
                    UMUIVerticalSlider(
                        label: "Gain (dB)",
                        value: $gain,
                        range: -48...12,
                        size: .normal,
                        labelWidth: 55
                    )
                    
                    UMUIVerticalSlider(
                        label: "Pitch",
                        value: $pitch,
                        range: 0...100,
                        size: .small,
                        inverted: true,
                        labelWidth: 40
                    )
                }
                
                Divider()
                
                // Monitor
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Gain Fader:")
                            .font(.caption2).bold()
                        Spacer()
                        Text(String(format: "%.2f dB", gain))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Color.accentColor)
                    }
                    HStack {
                        Text("Pitch (Inverted):")
                            .font(.caption2).bold()
                        Spacer()
                        Text(String(format: "%.1f", pitch))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Color.accentColor)
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
