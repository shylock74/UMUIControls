//
//  UMUIProgressBarView.swift
//  UMUIControls
//
//  A horizontal percentage progress bar featuring a sleek 4px rounded track,
//  smooth animated fill, and an optional jitter-free percentage indicator.
//

import SwiftUI

/// Defines the visual configuration for `UMUIProgressBarView`.
@available(macOS 11.0, *)
public struct UMUIProgressBarViewStyle: Sendable, Equatable {
    /// The primary color of the active progress bar fill. Defaults to accent color if nil.
    public var tintColor: Color?
    
    /// Public initializer to allow custom style configuration.
    /// - Parameter tintColor: An optional custom color for the progress bar fill.
    public init(tintColor: Color? = nil) {
        self.tintColor = tintColor
    }
}

/// A horizontal, deterministic progress bar with a sleek 4px height and rounded corners.
///
/// Features:
/// - 4px bar height with rounded corner radii (`2px`).
/// - Optional jitter-free percentage indicator on the right with monospaced digits.
/// - Supports integer (e.g. `75%`) or 1 decimal place (e.g. `75.5%`) formatting.
/// - Dynamic tinting using `tintColor` or system accent color.
///
/// Usage:
/// ```swift
/// UMUIProgressBarView(value: 0.75)
/// UMUIProgressBarView(value: 0.425, showPercentage: true, showDecimals: true)
/// ```
@available(macOS 11.0, *)
public struct UMUIProgressBarView: View {
    /// The normalized progress value between 0.0 and 1.0.
    public let value: Double
    
    /// Whether to display the percentage label on the right side.
    public let showPercentage: Bool
    
    /// Whether to display 1 decimal place in the percentage indicator (e.g., `75.5%` vs `75%`).
    public let showDecimals: Bool
    
    /// The visual style containing tint color preferences.
    public let style: UMUIProgressBarViewStyle
    
    /// Creates a new horizontal progress bar view with a style object.
    /// - Parameters:
    ///   - value: Normalized progress value from `0.0` to `1.0`.
    ///   - showPercentage: Whether to display percentage label on the right (default: `true`).
    ///   - showDecimals: Whether to show 1 decimal place (default: `false`).
    ///   - style: The style configuration containing color preferences.
    public init(
        value: Double,
        showPercentage: Bool = true,
        showDecimals: Bool = false,
        style: UMUIProgressBarViewStyle
    ) {
        self.value = min(max(value, 0.0), 1.0)
        self.showPercentage = showPercentage
        self.showDecimals = showDecimals
        self.style = style
    }
    
    /// Creates a new horizontal progress bar view with a direct tint color parameter.
    /// - Parameters:
    ///   - value: Normalized progress value from `0.0` to `1.0`.
    ///   - showPercentage: Whether to display percentage label on the right (default: `true`).
    ///   - showDecimals: Whether to show 1 decimal place (default: `false`).
    ///   - tintColor: Optional custom fill color (default: `nil`, uses accent color).
    public init(
        value: Double,
        showPercentage: Bool = true,
        showDecimals: Bool = false,
        tintColor: Color? = nil
    ) {
        self.value = min(max(value, 0.0), 1.0)
        self.showPercentage = showPercentage
        self.showDecimals = showDecimals
        self.style = UMUIProgressBarViewStyle(tintColor: tintColor)
    }
    
    private var percentageString: String {
        let percent = value * 100.0
        if showDecimals {
            return String(format: "%.1f%%", percent)
        } else {
            return String(format: "%.0f%%", percent)
        }
    }
    
    private var labelWidth: CGFloat {
        // Fixed width ensures zero jittering as text values fluctuate
        return showDecimals ? 40.0 : 32.0
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
            GeometryReader { geometry in
                let trackWidth = geometry.size.width
                let fillWidth = max(0, min(CGFloat(value) * trackWidth, trackWidth))
                let baseColor = style.tintColor ?? Color.accentColor
                
                ZStack(alignment: .leading) {
                    // Track background
                    RoundedRectangle(cornerRadius: 2.0)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 4.0)
                    
                    // Active progress fill
                    RoundedRectangle(cornerRadius: 2.0)
                        .fill(baseColor)
                        .frame(width: fillWidth, height: 4.0)
                }
                .position(x: trackWidth / 2, y: geometry.size.height / 2)
            }
            .frame(height: 4.0)
            
            if showPercentage {
                Text(percentageString)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(width: labelWidth, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIProgressBarView_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var progress: Double = 0.654
        
        var body: some View {
            VStack(spacing: 25) {
                Text("UMUIProgressBarView Previews")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Standard (Integer %):")
                        .font(.caption).bold()
                    UMUIProgressBarView(value: progress)
                    
                    Text("Decimal (1 Decimal Place %):")
                        .font(.caption).bold()
                    UMUIProgressBarView(value: progress, showPercentage: true, showDecimals: true)
                    
                    Text("Custom Tint Color (Orange, No % Label):")
                        .font(.caption).bold()
                    UMUIProgressBarView(value: progress, showPercentage: false, tintColor: .orange)
                    
                    Text("Custom Tint Color (Green, Decimal %):")
                        .font(.caption).bold()
                    UMUIProgressBarView(value: progress, showPercentage: true, showDecimals: true, tintColor: .green)
                }
                
                Divider()
                
                VStack(spacing: 8) {
                    Text("Adjust Progress:")
                        .font(.caption2).bold()
                    Slider(value: $progress, in: 0...1)
                }
            }
            .padding(25)
            .frame(width: 400)
        }
    }
    
    static var previews: some View {
        TestWrapper()
    }
}
#endif
