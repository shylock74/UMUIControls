//
//  UMUIFoldSection.swift
//  UMUIControls
//
//  A foldable section. The content is not built while it is folded, and the
//  folded state is remembered per `id`.
//

import SwiftUI

/// A section with a chevron header that folds its content away.
///
/// Usage:
/// ```swift
/// UMUIFoldSection(id: "denoise.advanced", title: "Advanced") {
///     UMUIFieldRow("Decay", labelWidth: 96) { ... }
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIFoldSection<Content: View>: View {

    public let title: String
    private let content: () -> Content
    @AppStorage private var isOpen: Bool

    public init(
        id: String,
        title: String,
        defaultOpen: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.content = content
        self._isOpen = AppStorage(wrappedValue: defaultOpen, "UMUI.Fold.\(id).open")
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeOut(duration: 0.15)) { isOpen.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.7))
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                        .frame(width: 10)
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer(minLength: 0)
                }
                .frame(height: 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(alignment: .leading, spacing: 7) {
                    content()
                }
                .padding(.bottom, 8)
            }
        }
    }
}
