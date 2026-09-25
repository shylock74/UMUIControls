//
//  UMUICurrencyField.swift
//  UMUIControls
//
//  A currency amount field with an optional leading label, a fixed trailing currency
//  symbol and the UMUITextField rounded-rect look. Typing edits a local copy of the
//  text: the bound Double is written only on commit (Return, focus loss, disappear),
//  so the parent does not re-render — and steal focus — on every keystroke.
//

import SwiftUI

/// The sizing options for `UMUICurrencyField`.
@available(macOS 11.0, *)
public enum UMUICurrencyFieldSize: Sendable, Equatable {
    /// Normal size using the standard `.body` font and paddings.
    case normal

    /// Small size (default) using the `.caption` font and compact paddings.
    case small
}

/// A currency amount field that writes its binding only when the edit is committed.
///
/// Usage:
/// ```swift
/// UMUICurrencyField(label: "Full Price:", value: $fullPrice, size: .normal)
/// ```
@available(macOS 11.0, *)
public struct UMUICurrencyField: View {
    /// The optional label displayed at the leading edge.
    public let label: String?

    /// The amount, written on commit and rounded to `decimals` places.
    @Binding public var value: Double

    /// The symbol shown after the amount, outside the editable text. Empty hides it.
    public let currency: String

    /// The number of fraction digits shown and kept on commit.
    public let decimals: Int

    /// The size option for the field (.normal or .small).
    public let size: UMUICurrencyFieldSize

    /// The width allocated for the leading label.
    public let labelWidth: CGFloat

    /// The width of the bordered field, currency symbol included.
    public let fieldWidth: CGFloat

    /// Creates a new currency field.
    public init(
        label: String? = nil,
        value: Binding<Double>,
        currency: String = "€",
        decimals: Int = 2,
        size: UMUICurrencyFieldSize = .small,
        labelWidth: CGFloat = 80,
        fieldWidth: CGFloat = 80
    ) {
        self.label = label
        self._value = value
        self.currency = currency
        self.decimals = max(decimals, 0)
        self.size = size
        self.labelWidth = labelWidth
        self.fieldWidth = fieldWidth
    }

    public var body: some View {
        if #available(macOS 12.0, *) {
            UMUICurrencyFieldModern(
                label: label,
                value: $value,
                currency: currency,
                decimals: decimals,
                size: size,
                labelWidth: labelWidth,
                fieldWidth: fieldWidth
            )
        } else {
            UMUICurrencyFieldLegacy(
                label: label,
                value: $value,
                currency: currency,
                decimals: decimals,
                size: size,
                labelWidth: labelWidth,
                fieldWidth: fieldWidth
            )
        }
    }
}

/// The modern implementation of UMUICurrencyField using FocusState.
@available(macOS 12.0, *)
struct UMUICurrencyFieldModern: View {
    let label: String?
    @Binding var value: Double
    let currency: String
    let decimals: Int
    let size: UMUICurrencyFieldSize
    let labelWidth: CGFloat
    let fieldWidth: CGFloat

    @State private var edit: UMUICurrencyEditState
    @FocusState private var isFocused: Bool

    init(
        label: String?,
        value: Binding<Double>,
        currency: String,
        decimals: Int,
        size: UMUICurrencyFieldSize,
        labelWidth: CGFloat,
        fieldWidth: CGFloat
    ) {
        self.label = label
        self._value = value
        self.currency = currency
        self.decimals = decimals
        self.size = size
        self.labelWidth = labelWidth
        self.fieldWidth = fieldWidth
        // Seed here rather than in onAppear: inside a disclosure group or a tab the
        // field can render before onAppear runs and would briefly show up empty.
        self._edit = State(initialValue: UMUICurrencyEditState(value: value.wrappedValue, decimals: decimals))
    }

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if let label = label {
                UMUICurrencyFieldLabel(label: label, size: size, width: labelWidth)
            }

            HStack(spacing: 4) {
                TextField("", text: $edit.text)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .font(size.font)
                    .multilineTextAlignment(.trailing)
                    .onSubmit { commitChanges() }
                    .onExitCommand { edit.revert() }

                UMUICurrencyFieldSymbol(currency: currency, size: size)
            }
            .modifier(UMUICurrencyFieldBox(isFocused: isFocused, size: size, width: fieldWidth))
        }
        .onChange(of: value) { newValue in
            // An outside change (another record selected, a sync) wins over a
            // half-typed edit, which would otherwise be committed into the wrong record.
            edit.sync(to: newValue, decimals: decimals)
        }
        .onChange(of: isFocused) { focused in
            if !focused {
                commitChanges()
            }
        }
        .onDisappear {
            commitChanges()
        }
    }

    private func commitChanges() {
        if let newValue = edit.commit(currency: currency, decimals: decimals), newValue != value {
            value = newValue
        }
    }
}

/// The legacy implementation of UMUICurrencyField supporting macOS 11 without FocusState.
@available(macOS 11.0, *)
struct UMUICurrencyFieldLegacy: View {
    let label: String?
    @Binding var value: Double
    let currency: String
    let decimals: Int
    let size: UMUICurrencyFieldSize
    let labelWidth: CGFloat
    let fieldWidth: CGFloat

    @State private var edit: UMUICurrencyEditState
    @State private var isFocused: Bool = false

    init(
        label: String?,
        value: Binding<Double>,
        currency: String,
        decimals: Int,
        size: UMUICurrencyFieldSize,
        labelWidth: CGFloat,
        fieldWidth: CGFloat
    ) {
        self.label = label
        self._value = value
        self.currency = currency
        self.decimals = decimals
        self.size = size
        self.labelWidth = labelWidth
        self.fieldWidth = fieldWidth
        self._edit = State(initialValue: UMUICurrencyEditState(value: value.wrappedValue, decimals: decimals))
    }

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if let label = label {
                UMUICurrencyFieldLabel(label: label, size: size, width: labelWidth)
            }

            HStack(spacing: 4) {
                TextField("", text: $edit.text, onEditingChanged: { editing in
                    isFocused = editing
                    if !editing {
                        commitChanges()
                    }
                }, onCommit: {
                    commitChanges()
                })
                .textFieldStyle(.plain)
                .font(size.font)
                .multilineTextAlignment(.trailing)
                .onExitCommand { edit.revert() }

                UMUICurrencyFieldSymbol(currency: currency, size: size)
            }
            .modifier(UMUICurrencyFieldBox(isFocused: isFocused, size: size, width: fieldWidth))
        }
        .onChange(of: value) { newValue in
            edit.sync(to: newValue, decimals: decimals)
        }
        .onDisappear {
            commitChanges()
        }
    }

    private func commitChanges() {
        if let newValue = edit.commit(currency: currency, decimals: decimals), newValue != value {
            value = newValue
        }
    }
}

// MARK: - Edit State

/// The text being edited plus the text last synchronized with the binding, so a
/// commit can tell whether the user actually typed anything.
struct UMUICurrencyEditState: Equatable {
    var text: String
    private(set) var syncedText: String

    init(value: Double, decimals: Int) {
        text = UMUICurrencyFormat.string(from: value, decimals: decimals)
        syncedText = text
    }

    mutating func sync(to value: Double, decimals: Int) {
        text = UMUICurrencyFormat.string(from: value, decimals: decimals)
        syncedText = text
    }

    mutating func revert() {
        text = syncedText
    }

    /// Returns the amount to write, or `nil` when the text is untouched or invalid
    /// (invalid text is reverted to the last synchronized value).
    mutating func commit(currency: String, decimals: Int) -> Double? {
        guard text != syncedText else { return nil }
        guard let parsed = UMUICurrencyFormat.parse(text, currency: currency, decimals: decimals) else {
            revert()
            return nil
        }
        text = UMUICurrencyFormat.string(from: parsed, decimals: decimals)
        syncedText = text
        return parsed
    }
}

// MARK: - Formatting

enum UMUICurrencyFormat {
    static func string(from value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }

    /// Parses "7,49", "7.49", "1.234,56", "1,234.56" or "7,49 €" regardless of the
    /// current locale, rounding to `decimals` places.
    static func parse(_ text: String, currency: String, decimals: Int) -> Double? {
        var cleaned = currency.isEmpty ? text : text.replacingOccurrences(of: currency, with: "")
        cleaned = cleaned.filter { !$0.isWhitespace && $0 != "'" }
        guard !cleaned.isEmpty else { return nil }

        let lastComma = cleaned.lastIndex(of: ",")
        let lastDot = cleaned.lastIndex(of: ".")
        if let comma = lastComma, let dot = lastDot {
            // Both present: whichever comes last separates the decimals, the other groups thousands.
            if comma > dot {
                cleaned = cleaned.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
            } else {
                cleaned = cleaned.replacingOccurrences(of: ",", with: "")
            }
        } else if cleaned.filter({ $0 == "," }).count > 1 {
            cleaned = cleaned.replacingOccurrences(of: ",", with: "")
        } else if cleaned.filter({ $0 == "." }).count > 1 {
            cleaned = cleaned.replacingOccurrences(of: ".", with: "")
        } else {
            cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        }

        guard let parsed = Double(cleaned), parsed.isFinite else { return nil }
        let scale = pow(10, Double(decimals))
        return (parsed * scale).rounded() / scale
    }
}

// MARK: - Shared Pieces

@available(macOS 11.0, *)
private extension UMUICurrencyFieldSize {
    var font: Font {
        switch self {
        case .normal:
            return .body
        case .small:
            return .caption
        }
    }
}

@available(macOS 11.0, *)
private struct UMUICurrencyFieldLabel: View {
    let label: String
    let size: UMUICurrencyFieldSize
    let width: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(size.font)
                .lineLimit(1)
                .foregroundColor(.primary)
            Spacer(minLength: 0)
        }
        .umLabelColumn(width)
    }
}

@available(macOS 11.0, *)
private struct UMUICurrencyFieldSymbol: View {
    let currency: String
    let size: UMUICurrencyFieldSize

    var body: some View {
        if !currency.isEmpty {
            Text(currency)
                .font(size.font)
                .foregroundColor(.secondary)
        }
    }
}

/// The UMUITextField rounded-rect chrome with the accent focus glow.
@available(macOS 11.0, *)
private struct UMUICurrencyFieldBox: ViewModifier {
    let isFocused: Bool
    let size: UMUICurrencyFieldSize
    let width: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, size == .small ? 8 : 10)
            .padding(.vertical, size == .small ? 4 : 6)
            .frame(width: width)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        isFocused ? Color.accentColor : Color.secondary.opacity(0.3),
                        lineWidth: isFocused ? 1.5 : 1.0
                    )
                    .shadow(color: isFocused ? Color.accentColor.opacity(0.25) : Color.clear, radius: isFocused ? 3 : 0)
            )
            .animation(.easeOut(duration: 0.12), value: isFocused)
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUICurrencyField_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var fullPrice = 14.99
        @State private var upgradePrice = 7.49

        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                UMUICurrencyField(label: "Full Price:", value: $fullPrice, size: .normal, labelWidth: 90)
                UMUICurrencyField(label: "Upgrade:", value: $upgradePrice, labelWidth: 90)

                Divider()

                Text("Binding (writes on Return or focus loss, Esc reverts): \(fullPrice) / \(upgradePrice)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Color.accentColor)
            }
            .padding(30)
            .frame(width: 450)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
