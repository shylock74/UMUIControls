//
//  UMUIColorPalettePicker.swift
//  UMUIControls
//
//  A premium, compact color swatch picker featuring customizable predefined palettes,
//  a dynamic custom color display indicator, and an integrated thread-safe macOS
//  native `NSColorSampler` eyedropper.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

/// Sizing modes for UMUIColorPalettePicker.
@available(macOS 11.0, *)
public enum UMUIColorPalettePickerSize: Sendable, Equatable {
    case normal
    case small
}

/// A compact color picker featuring customizable palette swatches and a native system-wide eyedropper.
///
/// If a custom color is picked using the eyedropper that is not in the predefined palette,
/// it dynamically renders a temporary "+ Custom" swatch.
/// Fully thread-safe, dispatching system callbacks cleanly off the background thread.
///
/// Usage:
/// ```swift
/// UMUIColorPalettePicker(label: "Fill Color", selection: $shapeFill, size: .normal)
/// ```
@available(macOS 11.0, *)
public struct UMUIColorPalettePicker: View {
    /// The optional label displayed on the leading edge.
    public let label: String?
    
    /// The selected color binding.
    @Binding public var selection: Color
    
    /// The custom list of predefined swatches.
    public let palette: [Color]
    
    /// The sizing mode of the color palette picker.
    public let size: UMUIColorPalettePickerSize
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    // MARK: - Default Palette
    
    /// A premium, harmonious default HSL-shaded color palette.
    public static let defaultPalette: [Color] = [
        .red, .orange, .yellow, .green, .umMint, .blue, .purple, .pink, .gray
    ]
    
    /// Creates a color palette picker.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - selection: Binding to the selected Color.
    ///   - palette: Predefined color swatch palette (defaults to a high-quality HSL-shaded list).
    ///   - size: Sizing mode (default is `.normal`).
    ///   - labelWidth: Width reserved for the label (default is `80`).
    public init(
        label: String? = nil,
        selection: Binding<Color>,
        palette: [Color] = defaultPalette,
        size: UMUIColorPalettePickerSize = .small,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self._selection = selection
        self.palette = palette
        self.size = size
        self.labelWidth = labelWidth
    }
    
    private var isCustomSelected: Bool {
        !palette.contains(selection)
    }
    
    private var swatchSize: CGFloat {
        return size == .normal ? 18 : 12
    }
    
    private var indicatorDotSize: CGFloat {
        return size == .normal ? 6 : 4
    }
    
    private var eyedropperSize: CGFloat {
        return size == .normal ? 20 : 14
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
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
            
            // Swatch Flow Container
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: size == .normal ? 8 : 6) {
                    // Predefined Palette Swatches
                    ForEach(palette, id: \.self) { color in
                        Button {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                selection = color
                            }
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: swatchSize, height: swatchSize)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    // Selected indicator dot
                                    Group {
                                        if selection == color {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: indicatorDotSize, height: indicatorDotSize)
                                                .shadow(color: .black.opacity(0.3), radius: 1)
                                                .transition(.scale)
                                        }
                                    }
                                )
                                .scaleEffect(selection == color ? 1.15 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Dynamic Custom Swatch
                    if isCustomSelected {
                        Circle()
                            .fill(selection)
                            .frame(width: swatchSize, height: swatchSize)
                            .overlay(
                                Circle()
                                    .stroke(Color.accentColor, lineWidth: size == .normal ? 2 : 1.2)
                            )
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: indicatorDotSize, height: indicatorDotSize)
                                    .shadow(color: .black.opacity(0.3), radius: 1)
                            )
                            .scaleEffect(1.15)
                            .help("Custom picked color")
                    }
                    
                    Divider()
                        .frame(height: size == .normal ? 14 : 10)
                    
                    // Native Eyedropper Button
                    Button {
                        triggerEyedropper()
                    } label: {
                        Image(systemName: "eyedropper")
                            .font(size == .normal ? .caption2 : .system(size: 8))
                            .foregroundColor(Color.secondary)
                            .frame(width: eyedropperSize, height: eyedropperSize)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .help("Pick a color from screen")
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Native macOS Eyedropper Helper
    
    private func triggerEyedropper() {
        #if canImport(AppKit)
        let sampler = NSColorSampler()
        sampler.show { color in
            guard let color = color else { return } // user cancelled
            let pickedColor = Color( color)
            
            // NSColorSampler triggers its callback on a system background thread.
            // We MUST return to the Main Thread for safety to write to the Binding!
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    self.selection = pickedColor
                }
            }
        }
        #endif
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIColorPalettePicker_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var fontColor: Color = .purple
        @State private var borderFill: Color = .init(red: 0.1, green: 0.6, blue: 0.8)
        
        var body: some View {
            VStack(spacing: 25) {
                Text("UMUIColorPalettePicker Previews")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Normal Size:")
                        .font(.caption).bold()
                    
                    UMUIColorPalettePicker(
                        label: "Font Color",
                        selection: $fontColor,
                        size: .normal
                    )
                    
                    Divider()
                    
                    Text("Small Size:")
                        .font(.caption).bold()
                    
                    UMUIColorPalettePicker(
                        label: "Border Color",
                        selection: $borderFill,
                        size: .small
                    )
                }
                
                Divider()
                
                // Color previews
                HStack(spacing: 20) {
                    VStack(alignment: .center, spacing: 6) {
                        Text("Font Color")
                            .font(.caption2).bold()
                        RoundedRectangle(cornerRadius: 6)
                            .fill(fontColor)
                            .frame(width: 80, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .center, spacing: 6) {
                        Text("Border Color")
                            .font(.caption2).bold()
                        RoundedRectangle(cornerRadius: 6)
                            .fill(borderFill)
                            .frame(width: 80, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
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
