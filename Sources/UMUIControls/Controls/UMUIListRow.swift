//
//  UMUIListRow.swift
//  UMUIControls
//
//  A selectable navigation row for sidebars and master lists: leading symbol,
//  title, optional subtitle, trailing detail or badge, hover and selection states.
//

import SwiftUI

/// Selection style for `UMUIListRow`.
@available(macOS 11.0, *)
public enum UMUIListRowSelectionStyle: Sendable, Equatable {
    /// Solid accent background fill with contrasting white or black text.
    case solid
    /// Subtle accent tinted background fill with standard primary text.
    case subtle
}

/// A selectable list row with hover feedback and an accent selection background.
///
/// Usage:
/// ```swift
/// ForEach(events) { event in
///     UMUIListRow(title: event.title,
///                 subtitle: event.date.formatted(),
///                 systemImage: "calendar",
///                 detail: "3",
///                 isSelected: event.id == selection) {
///         selection = event.id
///     }
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIListRow<Leading: View, Trailing: View>: View {
    /// Row title.
    public let title: String

    /// Optional second line.
    public let subtitle: String?

    /// Selection styling (solid or subtle tint).
    public let selectionStyle: UMUIListRowSelectionStyle

    /// Whether the row is the current selection.
    public let isSelected: Bool

    /// Called when the row is clicked.
    public let action: () -> Void

    /// Leading accessory (app icon, SF Symbol, thumbnail…).
    public let leading: Leading

    /// Trailing accessory (badge, detail text, status pill…).
    public let trailing: Trailing

    @State private var isHovered = false

    /// Creates a row with custom leading and trailing accessories.
    public init(
        title: String,
        subtitle: String? = nil,
        selectionStyle: UMUIListRowSelectionStyle = .subtle,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.selectionStyle = selectionStyle
        self.isSelected = isSelected
        self.action = action
        self.leading = leading()
        self.trailing = trailing()
    }

    @Environment(\.umAccentColor) private var envAccentColor
    @Environment(\.self) private var environment
    
    private var resolvedAccentColor: Color {
        envAccentColor ?? .accentColor
    }
    
    private var selectedForeground: Color {
        if selectionStyle == .subtle {
            return .primary
        }
        return resolvedAccentColor.umContrastingTextColor(in: environment)
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                leading
                    .foregroundColor(isSelected && selectionStyle == .solid ? selectedForeground : resolvedAccentColor)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(isSelected ? selectedForeground : .primary)
                    if let subtitle = subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 10))
                            .lineLimit(1)
                            .foregroundColor(isSelected && selectionStyle == .solid ? selectedForeground.opacity(0.8) : .secondary)
                    }
                }

                Spacer(minLength: 4)

                trailing
                    .foregroundColor(isSelected && selectionStyle == .solid ? selectedForeground.opacity(0.9) : .secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(backgroundColor)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeOut(duration: 0.1), value: isHovered)
    }

    private var backgroundColor: Color {
        if isSelected {
            return selectionStyle == .subtle ? resolvedAccentColor.opacity(0.15) : resolvedAccentColor
        }
        return isHovered ? Color.secondary.opacity(0.12) : Color.clear
    }
}

@available(macOS 11.0, *)
public extension UMUIListRow where Leading == AnyView {
    /// Creates a row with a standard SF symbol leading icon and custom trailing accessory.
    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        selectionStyle: UMUIListRowSelectionStyle = .solid,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            selectionStyle: selectionStyle,
            isSelected: isSelected,
            action: action,
            leading: {
                if let systemImage = systemImage {
                    return AnyView(
                        Image(systemName: systemImage)
                            .font(.system(size: 12))
                            .frame(width: 16)
                    )
                } else {
                    return AnyView(EmptyView())
                }
            },
            trailing: trailing
        )
    }
}

@available(macOS 11.0, *)
public extension UMUIListRow where Leading == AnyView, Trailing == UMUIListRowDetail {
    /// Creates a row with an optional trailing detail text.
    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        detail: String? = nil,
        selectionStyle: UMUIListRowSelectionStyle = .solid,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            selectionStyle: selectionStyle,
            isSelected: isSelected,
            action: action
        ) {
            UMUIListRowDetail(text: detail)
        }
    }
}

/// The default trailing accessory of `UMUIListRow`: a small monospaced detail, or nothing.
@available(macOS 11.0, *)
public struct UMUIListRowDetail: View {
    public let text: String?

    public init(text: String?) {
        self.text = text
    }

    public var body: some View {
        if let text = text, !text.isEmpty {
            Text(text)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIListRow_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var selection = 1

        var body: some View {
            VStack(spacing: 2) {
                ForEach(0 ..< 4, id: \.self) { i in
                    UMUIListRow(title: "Event \(i + 1)",
                                subtitle: "19 Sep 2026",
                                systemImage: "calendar",
                                detail: "\(i * 2)",
                                isSelected: selection == i) {
                        selection = i
                    }
                }
            }
            .padding(10)
            .frame(width: 260)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
