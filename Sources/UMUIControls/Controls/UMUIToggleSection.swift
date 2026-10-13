//
//  UMUIToggleSection.swift
//  UMUIControls
//
//  A processor row: title and a switch on one line. The content below it is only built
//  while the switch is on, so a settings page with many processors stays cheap.
//

import SwiftUI

/// A hairline-separated row with a title, an optional accessory and a mini switch on the right.
/// The content is indented under the title and **does not exist** while `isOn` is `false`.
///
/// Usage:
/// ```swift
/// UMUIToggleSection("Denoise", isOn: $denoise.enable) {
///     UMUIFieldRow("Reduction", labelWidth: 96) {
///         UMUIScrubField(value: $denoise.reduction, range: 0...36, unit: "dB")
///     }
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIToggleSection<Accessory: View, Content: View>: View {

    public let title: String
    @Binding public var isOn: Bool
    public let indent: CGFloat
    public let showsDivider: Bool
    private let accessory: Accessory
    private let content: () -> Content

    public init(
        _ title: String,
        isOn: Binding<Bool>,
        indent: CGFloat = 12,
        showsDivider: Bool = true,
        @ViewBuilder accessory: () -> Accessory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._isOn = isOn
        self.indent = indent
        self.showsDivider = showsDivider
        self.accessory = accessory()
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsDivider { Divider() }
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                accessory
                Spacer(minLength: 0)
                Toggle("", isOn: $isOn.animation(.easeOut(duration: 0.15)))
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.mini)
            }
            .frame(height: 26)
            .contentShape(Rectangle())

            if isOn {
                VStack(alignment: .leading, spacing: 7) {
                    content()
                }
                .padding(.leading, indent)
                .padding(.bottom, 10)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.25))
                        .frame(width: 1)
                        .padding(.bottom, 10)
                }
                .transition(.opacity)
            }
        }
    }
}

@available(macOS 11.0, *)
public extension UMUIToggleSection where Accessory == EmptyView {
    init(
        _ title: String,
        isOn: Binding<Bool>,
        indent: CGFloat = 12,
        showsDivider: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(title, isOn: isOn, indent: indent, showsDivider: showsDivider,
                  accessory: { EmptyView() }, content: content)
    }
}
