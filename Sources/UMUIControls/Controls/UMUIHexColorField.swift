//
//  UMUIHexColorField.swift
//  UMUIControls
//
//  A color token editor bound to a "#RRGGBB" string: a swatch that opens the
//  system color panel next to an editable hex field. Pairs with the
//  `Color(umHex:)` / `umHexString` helpers.
//

import SwiftUI

/// A color token field that stores its value as a `#RRGGBB` hex string.
///
/// Invalid text is not written: the binding only changes when the field holds
/// a parsable color, so a half-typed value never reaches the model.
///
/// Usage:
/// ```swift
/// UMUIHexColorField(label: "Primary", hex: $brand.primaryHexColor)
/// ```
@available(macOS 12.0, *)
public struct UMUIHexColorField: View {
    /// Optional leading label.
    public let label: String?

    /// The bound `#RRGGBB` string.
    @Binding public var hex: String

    /// Width allocated for the label.
    public let labelWidth: CGFloat

    public init(label: String? = nil, hex: Binding<String>, labelWidth: CGFloat = 80) {
        self.label = label
        self._hex = hex
        self.labelWidth = labelWidth
    }

    public var body: some View {
        HStack(spacing: 6) {
            if let label = label {
                Text(label)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(width: labelWidth, alignment: .leading)
            }

            ColorPicker("", selection: colorBinding, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 34)

            UMUITextField(placeholder: "#RRGGBB", value: textBinding)
                .frame(width: 90)

            Spacer(minLength: 0)
        }
    }

    private var colorBinding: Binding<Color> {
        Binding(
            get: { Color(umHex: hex) ?? .black },
            set: { newColor in
                if let newHex = newColor.umHexString, newHex.caseInsensitiveCompare(hex) != .orderedSame {
                    hex = newHex
                }
            }
        )
    }

    private var textBinding: Binding<String> {
        Binding(
            get: { hex },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                let normalized = trimmed.hasPrefix("#") ? trimmed.uppercased() : "#" + trimmed.uppercased()
                if Color(umHex: normalized) != nil, normalized != hex {
                    hex = normalized
                }
            }
        )
    }
}

// MARK: - Hex helpers

@available(macOS 11.0, *)
public extension Color {
    /// Creates a color from `#RGB`, `#RRGGBB` or `#RRGGBBAA` (the `#` is optional).
    /// Returns `nil` for anything else.
    init?(umHex string: String) {
        var text = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") {
            text.removeFirst()
        }
        if text.count == 3 {
            text = text.map { "\($0)\($0)" }.joined()
        }
        guard text.count == 6 || text.count == 8, let value = UInt64(text, radix: 16) else {
            return nil
        }
        let r, g, b, a: Double
        if text.count == 8 {
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8) & 0xFF) / 255
            a = Double(value & 0xFF) / 255
        } else {
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// The color as `#RRGGBB` in sRGB, or `nil` when it cannot be converted.
    var umHexString: String? {
        #if os(macOS)
        guard let rgb = NSColor(self).usingColorSpace(.sRGB) else {
            return nil
        }
        let r = Int((rgb.redComponent * 255).rounded())
        let g = Int((rgb.greenComponent * 255).rounded())
        let b = Int((rgb.blueComponent * 255).rounded())
        return String(format: "#%02X%02X%02X", max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)))
        #else
        return nil
        #endif
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct UMUIHexColorField_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var primary = "#1D3557"
        @State private var accent = "#E63946"

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                UMUIHexColorField(label: "Primary", hex: $primary)
                UMUIHexColorField(label: "Accent", hex: $accent)
            }
            .padding(20)
            .frame(width: 320)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
