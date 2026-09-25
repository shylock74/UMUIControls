//
//  UMUIPicker.swift
//  UMUIControls
//
//  A premium, customizable picker / dropdown menu control combining an optional leading label,
//  a rounded-rect border style matching UMUI controls, sizing modes (.normal / .small),
//  and a native popup menu presentation.
//

import SwiftUI

/// Sizing modes for `UMUIPicker`.
@available(macOS 11.0, *)
public enum UMUIPickerSize: Sendable, Equatable {
    case normal
    case small
}

/// A premium visual picker control displaying an active choice inside a styled rounded-rect button,
/// which triggers a dropdown menu to select among options.
@available(macOS 11.0, *)
public struct UMUIPicker: View {
    /// The optional label displayed at the leading edge.
    public let label: String?
    
    /// The list of options to display.
    public let options: [String]
    
    /// Binding to the selected option string.
    @Binding public var selection: String
    
    /// Sizing mode (.normal or .small).
    public let size: UMUIPickerSize
    
    /// Horizontal width reserved for the optional leading label.
    public let labelWidth: CGFloat
    
    /// Optional placeholder displayed when selection is empty.
    public let placeholder: String?
    
    @State private var isHovered: Bool = false
    
    /// Creates a new single-selection picker.
    public init(
        label: String? = nil,
        options: [String],
        selection: Binding<String>,
        size: UMUIPickerSize = .small,
        labelWidth: CGFloat = 80,
        placeholder: String? = nil
    ) {
        self.label = label
        self.options = options
        self._selection = selection
        self.size = size
        self.labelWidth = labelWidth
        self.placeholder = placeholder
    }
    
    private var optionFont: Font {
        size == .normal ? .body : .caption
    }
    
    private var horizontalPadding: CGFloat {
        size == .normal ? 10 : 8
    }
    
    private var verticalPadding: CGFloat {
        size == .normal ? 5 : 4
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Optional Leading Label
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
            
            // Styled Dropdown Menu Button
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        HStack {
                            Text(option)
                            if selection == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selection.isEmpty ? (placeholder ?? "Select…") : selection)
                        .font(optionFont)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer(minLength: 2)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: size == .normal ? 9 : 8, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(isHovered ? 0.35 : 0.18), lineWidth: 1)
                )
            }
            .menuStyle(.borderlessButton)
            .fixedSize(horizontal: true, vertical: false)
            .onHover { isHovered = $0 }
        }
    }
}

// MARK: - Generic Enum & CaseIterable Extension

@available(macOS 11.0, *)
extension UMUIPicker {
    /// Creates a picker bound to any `Hashable & CaseIterable` enum or collection.
    public init<T: Hashable & CaseIterable>(
        label: String? = nil,
        selection: Binding<T>,
        titleProvider: @escaping (T) -> String = { "\($0)" },
        size: UMUIPickerSize = .small,
        labelWidth: CGFloat = 80,
        placeholder: String? = nil
    ) {
        let stringOptions = Array(T.allCases).map { titleProvider($0) }
        let binding = Binding<String>(
            get: { titleProvider(selection.wrappedValue) },
            set: { newTitle in
                if let match = Array(T.allCases).first(where: { titleProvider($0) == newTitle }) {
                    selection.wrappedValue = match
                }
            }
        )
        self.init(
            label: label,
            options: stringOptions,
            selection: binding,
            size: size,
            labelWidth: labelWidth,
            placeholder: placeholder
        )
    }
}
