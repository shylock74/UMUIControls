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

/// A compact color picker featuring customizable palette swatches and a native system-wide eyedropper.
///
/// If a custom color is picked using the eyedropper that is not in the predefined palette,
/// it dynamically renders a temporary "+ Custom" swatch.
/// Fully thread-safe, dispatching system callbacks cleanly off the background thread.
///
/// Usage:
/// ```swift
/// UMUIColorPalettePicker(label: "Fill Color", selection: $shapeFill)
/// ```
public struct UMUIColorPalettePicker: View {
    /// The optional label displayed on the leading edge.
    public let label: String?
    
    /// The selected color binding.
    @Binding public var selection: Color
    
    /// The custom list of predefined swatches.
    public let palette: [Color]
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    // MARK: - Default Palette
    
    /// A premium, harmonious default HSL-shaded color palette.
    public static let defaultPalette: [Color] = [
        .red, .orange, .yellow, .green, .mint, .blue, .purple, .pink, .gray
    ]
    
    /// Creates a color palette picker.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - selection: Binding to the selected Color.
    ///   - palette: Predefined color swatch palette (defaults to a high-quality HSL-shaded list).
    ///   - labelWidth: Width reserved for the label (default is `80`).
    public init(
        label: String? = nil,
        selection: Binding<Color>,
        palette: [Color] = defaultPalette,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self._selection = selection
        self.palette = palette
        self.labelWidth = labelWidth
    }
    
    private var isCustomSelected: Bool {
        !palette.contains(selection)
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
            
            // Swatch Flow Container
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Predefined Palette Swatches
                    ForEach(palette, id: \.self) { color in
                        Button {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                selection = color
                            }
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 18, height: 18)
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
                                                .frame(width: 6, height: 6)
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
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle()
                                    .stroke(Color.accentColor, lineWidth: 2)
                            )
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                    .shadow(color: .black.opacity(0.3), radius: 1)
                            )
                            .scaleEffect(1.15)
                            .help("Custom picked color")
                    }
                    
                    Divider()
                        .frame(height: 14)
                    
                    // Native Eyedropper Button
                    Button {
                        triggerEyedropper()
                    } label: {
                        Image(systemName: "eyedropper")
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                            .frame(width: 20, height: 20)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
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
            let pickedColor = Color(nsColor: color)
            
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
struct UMUIColorPalettePicker_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var fontColor: Color = .purple
        @State private var borderFill: Color = .init(red: 0.1, green: 0.6, blue: 0.8)
        
        var body: some View {
            VStack(spacing: 25) {
                Text("UMUIColorPalettePicker Previews")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Select a color swatch or click the eyedropper tool to pick any color on your monitor.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    UMUIColorPalettePicker(
                        label: "Font Color",
                        selection: $fontColor
                    )
                    
                    UMUIColorPalettePicker(
                        label: "Border Color",
                        selection: $borderFill
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
