//
//  UMUIColorWell.swift
//  UMUIControls
//
//  A labeled color swatch that opens the system color panel, with the picked
//  color written next to it as a hex token (and its opacity, when enabled).
//

import SwiftUI

/// Sizing modes for `UMUIColorWell`.
@available(macOS 11.0, *)
public enum UMUIColorWellSize: Sendable, Equatable {
    case normal
    case small
}

/// A color well with an optional leading label.
///
/// Unlike `UMUIColorPalettePicker` it offers no preset swatches: it is the
/// plain "pick any color" row of a settings form, bound to a SwiftUI `Color`.
///
/// Usage:
/// ```swift
/// UMUIColorWell(label: "Text Color", color: $textColor, supportsOpacity: true)
/// ```
@available(macOS 11.0, *)
public struct UMUIColorWell: View {
    /// The optional label displayed at the leading edge.
    public let label: String?

    /// The bound color.
    @Binding public var color: Color

    /// Whether the color panel offers an opacity slider.
    public let supportsOpacity: Bool

    /// Whether the hex token of the color is shown after the swatch.
    public let showsValue: Bool

    /// Sizing mode (.normal or .small).
    public let size: UMUIColorWellSize

    /// Minimum width of the label column; a longer label widens it instead of being truncated.
    public let labelWidth: CGFloat

    /// Creates a color well.
    public init(
        label: String? = nil,
        color: Binding<Color>,
        supportsOpacity: Bool = false,
        showsValue: Bool = true,
        size: UMUIColorWellSize = .small,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self._color = color
        self.supportsOpacity = supportsOpacity
        self.showsValue = showsValue
        self.size = size
        self.labelWidth = labelWidth
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(size == .normal ? .body : .caption)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
                .umLabelColumn(labelWidth)
            }

            ColorPicker("", selection: $color, supportsOpacity: supportsOpacity)
                .labelsHidden()
                .controlSize(size == .normal ? .regular : .small)
                .fixedSize()

            if showsValue {
                Text(valueText)
                    .font(.system(size: size == .normal ? 11 : 10, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }

    /// "#RRGGBB", followed by the opacity when the panel lets it change.
    private var valueText: String {
        let hex = color.umHexString ?? ""
        guard supportsOpacity else {
            return hex
        }
        #if os(macOS)
        let alpha = NSColor(color).usingColorSpace(.sRGB)?.alphaComponent ?? 1
        return hex + String(format: " · %d%%", Int((alpha * 100).rounded()))
        #else
        return hex
        #endif
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIColorWell_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var text = Color.white
        @State private var background = Color.black.opacity(0.6)

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                UMUIColorWell(label: "Text Color", color: $text)
                UMUIColorWell(label: "Background", color: $background, supportsOpacity: true)
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
