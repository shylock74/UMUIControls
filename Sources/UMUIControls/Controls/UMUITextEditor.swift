//
//  UMUITextEditor.swift
//  UMUIControls
//
//  A multi-line text editor with an optional label on top, placeholder, the same
//  rounded-rect border and focus glow as UMUITextField, a 0.3-second debounced
//  binding, and an optional ⌘↩ submit action.
//

import SwiftUI

/// The sizing options for `UMUITextEditor`.
@available(macOS 13.0, *)
public enum UMUITextEditorSize: Sendable, Equatable {
    /// Normal size using the standard `.body` font.
    case normal

    /// Small size using the `.caption` font.
    case small
}

/// A premium multi-line text input with label, placeholder, focus glow, debounce and ⌘↩ submit.
///
/// Keystrokes edit a local copy; the binding is written `debounceInterval` (0.3 s) after the last keystroke,
/// immediately on blur, on disappear, and right before `onSubmit` runs.
///
/// Usage:
/// ```swift
/// UMUITextEditor(label: "Mission", placeholder: "Why the brand exists…", value: $mission)
/// UMUITextEditor(placeholder: "Type your answer…", value: $answer, minHeight: 44) {
///     send()
/// }
/// ```
@available(macOS 13.0, *)
public struct UMUITextEditor: View {
    /// Optional label shown above the editor.
    public let label: String?

    /// Placeholder shown while the editor is empty.
    public let placeholder: String

    /// The underlying binding, written on debounce, blur, disappear or submit.
    @Binding public var value: String

    /// Sizing mode.
    public let size: UMUITextEditorSize

    /// Minimum height of the editing area.
    public let minHeight: CGFloat

    /// Maximum height of the editing area; `nil` lets the editor grow freely.
    public let maxHeight: CGFloat?

    /// Monospaced font, for code, Markdown or prompts.
    public let isMonospaced: Bool

    /// Delay before keystrokes reach the binding. `0` writes on every keystroke,
    /// for inputs whose value is read by a button next to them (chat composers).
    public let debounceInterval: TimeInterval

    /// Called on ⌘↩ after the binding has been synchronized. `nil` disables the shortcut.
    public let onSubmit: (() -> Void)?

    @State private var localText: String = ""
    @State private var debouncer = UMUITextEditorDebouncer()
    @FocusState private var isFocused: Bool

    public init(
        label: String? = nil,
        placeholder: String = "",
        value: Binding<String>,
        size: UMUITextEditorSize = .small,
        minHeight: CGFloat = 60,
        maxHeight: CGFloat? = nil,
        isMonospaced: Bool = false,
        debounceInterval: TimeInterval = 0.3,
        onSubmit: (() -> Void)? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._value = value
        self.size = size
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.isMonospaced = isMonospaced
        self.debounceInterval = debounceInterval
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = label {
                Text(label)
                    .font(size == .small ? .caption : .body)
                    .foregroundColor(.primary)
            }

            ZStack(alignment: .topLeading) {
                if localText.isEmpty && !placeholder.isEmpty {
                    Text(placeholder)
                        .font(editorFont)
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $localText)
                    .font(editorFont)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .modifier(UMUITextEditorSubmitModifier(isEnabled: onSubmit != nil) {
                        submit()
                    })
            }
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .padding(.horizontal, size == .small ? 4 : 6)
            .padding(.vertical, size == .small ? 4 : 6)
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
        .onAppear {
            localText = value
        }
        .onChange(of: value) { newValue in
            if localText != newValue {
                localText = newValue
            }
        }
        .onChange(of: localText) { _ in
            startDebounce()
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

    private var editorFont: Font {
        let base: Font = size == .small ? .caption : .body
        return isMonospaced ? base.monospaced() : base
    }

    private func startDebounce() {
        let currentText = localText
        guard debounceInterval > 0 else {
            if value != currentText {
                value = currentText
            }
            return
        }
        debouncer.debounce(delay: debounceInterval) {
            if self.value != currentText {
                self.value = currentText
            }
        }
    }

    private func commitChanges() {
        debouncer.cancel()
        if value != localText {
            value = localText
        }
    }

    private func submit() {
        commitChanges()
        onSubmit?()
    }
}

/// Installs the ⌘↩ handler where `onKeyPress` exists (macOS 14+).
@available(macOS 13.0, *)
private struct UMUITextEditorSubmitModifier: ViewModifier {
    let isEnabled: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        if #available(macOS 14.0, *), isEnabled {
            content.onKeyPress(.return, phases: .down) { press in
                guard press.modifiers.contains(.command) else { return .ignored }
                action()
                return .handled
            }
        } else {
            content
        }
    }
}

/// Main-queue debouncer, same policy as the one in UMUITextField.
private final class UMUITextEditorDebouncer {
    private var workItem: DispatchWorkItem?

    func debounce(delay: Double, action: @escaping () -> Void) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }

    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 14.0, *)
struct UMUITextEditor_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var mission = ""
        @State private var markdown = "## Rules\n- Never use emoji"

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                UMUITextEditor(label: "Mission", placeholder: "Why the brand exists…", value: $mission)
                UMUITextEditor(label: "Guidelines (Markdown)", value: $markdown, size: .normal, minHeight: 100, isMonospaced: true)
            }
            .padding(20)
            .frame(width: 360)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
