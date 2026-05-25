//
//  UMUISlider.swift
//  UMUIControls
//
//  A premium, Control Center-style horizontal slider featuring a glassy track,
//  dynamic accent-colored fill, click-to-snap gesture tracking, and an interactive
//  grab handle (thumb) that scales up dynamically on hover or drag.
//

import SwiftUI

/// Sizing modes for UMUISlider.
public enum UMUISliderSize: Sendable, Equatable {
    case normal
    case small
}

/// A premium, customizable horizontal slider styled similarly to macOS Control Center controls.
///
/// Features click-to-snap, dragging, and a clean minimalist design where the circular
/// grab thumb remains hidden and zooms into view only when the mouse hovers or drags.
///
/// Usage:
/// ```swift
/// UMUISlider(label: "Brightness", value: $brightness, size: .normal)
/// ```
public struct UMUISlider: View {
    /// The optional label displayed on the leading edge.
    public let label: String?
    
    /// The underlying binding value adjusted by the slider.
    @Binding public var value: Double
    
    /// The range for the slider's value (default is 0...1).
    public let range: ClosedRange<Double>
    
    /// The sizing mode of the slider.
    public let size: UMUISliderSize
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    // MARK: - Internal States
    
    @State private var isDragging: Bool = false
    @State private var isHovered: Bool = false
    
    /// Creates a new horizontal slider.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - value: Binding to the double value.
    ///   - range: Active bounds for the value (default is `0...1`).
    ///   - size: Sizing mode (default is `.normal`).
    ///   - labelWidth: Horizontal width reserved for label (default is `80`).
    public init(
        label: String? = nil,
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...1,
        size: UMUISliderSize = .small,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.size = size
        self.labelWidth = labelWidth
    }
    
    private var fraction: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0.0 }
        return min(max((value - range.lowerBound) / span, 0.0), 1.0)
    }
    
    private var trackHeight: CGFloat {
        return size == .normal ? 12 : 8
    }
    
    private var thumbSize: CGFloat {
        return size == .normal ? 16 : 12
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
            
            // Slider Component View
            GeometryReader { geometry in
                let width = geometry.size.width
                let fillWidth = CGFloat(fraction) * width
                let tSize = thumbSize
                let tHeight = trackHeight
                
                ZStack(alignment: .leading) {
                    // Backglass track
                    RoundedRectangle(cornerRadius: tHeight / 2)
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: tHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: tHeight / 2)
                                .stroke(Color.secondary.opacity(0.15), lineWidth: 0.5)
                        )
                    
                    // Front active fill
                    RoundedRectangle(cornerRadius: tHeight / 2)
                        .fill(Color.accentColor)
                        .frame(width: fillWidth, height: tHeight)
                    
                    // Circular Grab Handle (Thumb) - scales up on hover/drag
                    Circle()
                        .fill(Color.white)
                        .frame(width: tSize, height: tSize)
                        .shadow(color: .black.opacity(0.25), radius: 1.5, y: 1)
                        .offset(x: max(0, min(fillWidth - tSize / 2, width - tSize)))
                        .scaleEffect(isHovered || isDragging ? 1.0 : 0.0)
                        .opacity(isHovered || isDragging ? 1.0 : 0.0)
                }
                .frame(height: tSize)
                .contentShape(Rectangle())
                .onHover { hovering in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                        isHovered = hovering
                    }
                }
                // Taps/Drags tracking using zero-distance gesture
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            let locationX = gesture.location.x
                            let percent = min(max(Double(locationX / width), 0.0), 1.0)
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
            .frame(height: thumbSize)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct UMUISlider_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var brightness: Double = 0.65
        @State private var opacity: Double = 1.0
        
        var body: some View {
            VStack(spacing: 25) {
                Text("UMUISlider Previews")
                    .font(.headline)
                
                Text("Move your cursor over a slider to reveal its grab thumb.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 20) {
                    Text("Normal Sized Brightness:")
                        .font(.caption).bold()
                    UMUISlider(
                        label: "Brightness",
                        value: $brightness,
                        range: 0...1,
                        size: .normal
                    )
                    
                    Divider()
                    
                    Text("Small Sized Opacity:")
                        .font(.caption).bold()
                    UMUISlider(
                        label: "Opacity",
                        value: $opacity,
                        range: 0...1,
                        size: .small
                    )
                }
                
                Divider()
                
                // Monitor
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Brightness:")
                            .font(.caption2).bold()
                        Spacer()
                        Text(String(format: "%.1f%%", brightness * 100))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Color.accentColor)
                    }
                    HStack {
                        Text("Opacity:")
                            .font(.caption2).bold()
                        Spacer()
                        Text(String(format: "%.0f%%", opacity * 100))
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
