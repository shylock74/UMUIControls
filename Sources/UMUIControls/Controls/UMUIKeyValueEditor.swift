//
//  UMUIKeyValueEditor.swift
//  UMUIControls
//
//  An editable list of key/value pairs (custom attributes, metadata, variables)
//  with add and remove buttons, built from UMUITextField rows.
//

import SwiftUI

/// One entry edited by `UMUIKeyValueEditor`.
@available(macOS 11.0, *)
public struct UMUIKeyValuePair: Identifiable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var key: String
    public var value: String

    public init(id: UUID = UUID(), key: String = "", value: String = "") {
        self.id = id
        self.key = key
        self.value = value
    }
}

/// An editable key/value table.
///
/// Each row is a pair of debounced `UMUITextField`s plus a remove button; the
/// footer button appends an empty row.
///
/// Usage:
/// ```swift
/// @State private var pairs: [UMUIKeyValuePair] = []
/// UMUIKeyValueEditor(pairs: $pairs, keyPlaceholder: "Attribute", valuePlaceholder: "Value")
/// ```
@available(macOS 12.0, *)
public struct UMUIKeyValueEditor: View {
    /// The edited pairs.
    @Binding public var pairs: [UMUIKeyValuePair]

    /// Placeholder of the key column.
    public let keyPlaceholder: String

    /// Placeholder of the value column.
    public let valuePlaceholder: String

    /// Title of the add button.
    public let addTitle: String

    /// Width of the key column.
    public let keyWidth: CGFloat

    public init(
        pairs: Binding<[UMUIKeyValuePair]>,
        keyPlaceholder: String = "Key",
        valuePlaceholder: String = "Value",
        addTitle: String = "Add",
        keyWidth: CGFloat = 110
    ) {
        self._pairs = pairs
        self.keyPlaceholder = keyPlaceholder
        self.valuePlaceholder = valuePlaceholder
        self.addTitle = addTitle
        self.keyWidth = keyWidth
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(pairs) { pair in
                HStack(spacing: 6) {
                    UMUITextField(placeholder: keyPlaceholder, value: keyBinding(for: pair.id))
                        .frame(width: keyWidth)
                    UMUITextField(placeholder: valuePlaceholder, value: valueBinding(for: pair.id))
                    Button {
                        pairs.removeAll { $0.id == pair.id }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Remove")
                }
            }

            UMUIMiniButton(addTitle, systemImage: "plus") {
                pairs.append(UMUIKeyValuePair())
            }
        }
    }

    private func keyBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { pairs.first { $0.id == id }?.key ?? "" },
            set: { newValue in
                if let index = pairs.firstIndex(where: { $0.id == id }), pairs[index].key != newValue {
                    pairs[index].key = newValue
                }
            }
        )
    }

    private func valueBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { pairs.first { $0.id == id }?.value ?? "" },
            set: { newValue in
                if let index = pairs.firstIndex(where: { $0.id == id }), pairs[index].value != newValue {
                    pairs[index].value = newValue
                }
            }
        )
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct UMUIKeyValueEditor_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var pairs = [
            UMUIKeyValuePair(key: "Audience", value: "Young professionals"),
            UMUIKeyValuePair(key: "Emoji", value: "Never")
        ]

        var body: some View {
            UMUIKeyValueEditor(pairs: $pairs, keyPlaceholder: "Attribute")
                .padding(20)
                .frame(width: 360)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
