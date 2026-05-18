//
//  UMUITextField.swift
//  UMUIControls
//
//  A premium, customizable text field combining an optional label, custom rounded-rect
//  border style, active focus glow, optional password security visibility toggling,
//  and a non-blocking 0.3-second debouncing binding synchronization system.
//

import SwiftUI

/// The sizing options for `UMUITextField`.
public enum UMUITextFieldSize: Sendable, Equatable {
    /// Normal size (default) using standard `.body` font and paddings.
    case normal
    
    /// Small size using standard `.caption` font and compact paddings.
    case small
}

/// A premium, customizable text input control with focus rings, sizing, password eye toggle, and debouncing.
///
/// Usage:
/// ```swift
/// UMUITextField(label: "Username", value: $username)
/// UMUITextField(label: "Password", value: $password, isSecure: true)
/// ```
public struct UMUITextField: View {
    /// The optional label displayed at the leading edge.
    public let label: String?
    
    /// The placeholder text shown when the field is empty.
    public let placeholder: String
    
    /// The underlying binding value updated on debounce/commit.
    @Binding public var value: String
    
    /// The size option for the field (.normal or .small).
    public let size: UMUITextFieldSize
    
    /// Whether the text field acts as a secure password field with visibility toggle.
    public let isSecure: Bool
    
    /// The width allocated for the leading label.
    public let labelWidth: CGFloat
    
    // MARK: - Internal States
    
    /// The local text buffer that updates instantly with keystrokes.
    @State private var localText: String = ""
    
    /// The visibility state for secure fields.
    @State private var isPasswordVisible: Bool = false
    
    /// Thread-safe Dispatch debouncer to prevent @MainActor clogging.
    @State private var debouncer = TextFieldDebouncer()
    
    /// SwiftUI focus tracker.
    @FocusState private var isFocused: Bool
    
    /// Creates a new premium text field.
    /// - Parameters:
    ///   - label: Optional leading label string.
    ///   - placeholder: Placeholder text (default is empty).
    ///   - value: Binding to the text value.
    ///   - size: Sizing option (default is `.normal`).
    ///   - isSecure: Whether to enable secure password input with eye toggle (default is `false`).
    ///   - labelWidth: Width allocated for the label (default is `80`).
    public init(
        label: String? = nil,
        placeholder: String = "",
        value: Binding<String>,
        size: UMUITextFieldSize = .small,
        isSecure: Bool = false,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self.placeholder = placeholder
        self._value = value
        self.size = size
        self.isSecure = isSecure
        self.labelWidth = labelWidth
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
            // Leading Label (if provided)
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(labelFont)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }
            
            // Text Field Input Container
            HStack(spacing: 4) {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $localText)
                        .focused($isFocused)
                        .textFieldStyle(.plain)
                        .font(fieldFont)
                        .onSubmit { commitChanges() }
                } else {
                    TextField(placeholder, text: $localText)
                        .focused($isFocused)
                        .textFieldStyle(.plain)
                        .font(fieldFont)
                        .onSubmit { commitChanges() }
                }
                
                // Secure Visibility Toggle
                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                        // Programmatically retain keyboard focus
                        isFocused = true
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(size == .small ? .caption2 : .body)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                }
            }
            .padding(.horizontal, size == .small ? 8 : 10)
            .padding(.vertical, size == .small ? 4 : 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(nsColor: .controlBackgroundColor))
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
        // Sync local buffer on appear and when external binding changes
        .onAppear {
            localText = value
        }
        .onChange(of: value) { newValue in
            if localText != newValue {
                localText = newValue
            }
        }
        // Debounce text updates after key strokes
        .onChange(of: localText) { _ in
            startDebounce()
        }
        // Commit immediately on blur (losing focus)
        .onChange(of: isFocused) { focused in
            if !focused {
                commitChanges()
            }
        }
        // Commit immediately on disappear
        .onDisappear {
            commitChanges()
        }
    }
    
    // MARK: - Helper Computeds
    
    private var fieldFont: Font {
        switch size {
        case .normal:
            return .body
        case .small:
            return .caption
        }
    }
    
    private var labelFont: Font {
        switch size {
        case .normal:
            return .body
        case .small:
            return .caption
        }
    }
    
    // MARK: - Synchronization & Debounce Logic
    
    private func startDebounce() {
        let currentText = localText
        debouncer.debounce(delay: 0.3) {
            // Verify changes in the background thread!
            if self.value != currentText {
                // Return to the Main Queue ONLY for the binding state write
                DispatchQueue.main.async {
                    self.value = currentText
                }
            }
        }
    }
    
    private func commitChanges() {
        debouncer.cancel()
        if value != localText {
            value = localText
        }
    }
}

// MARK: - Debouncer Engine

/// A thread-safe, background-managed debouncer that isolates delay-timers and state checks from the Main Actor.
private final class TextFieldDebouncer {
    private var workItem: DispatchWorkItem?
    
    func debounce(delay: Double, action: @escaping () -> Void) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        
        // Execute the delay timer and logic verification in a background interactive queue
        DispatchQueue.global(qos: .userInteractive).asyncAfter(
            deadline: .now() + delay,
            execute: newWorkItem
        )
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}

// MARK: - Previews

#if DEBUG
struct UMUITextField_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var textNormal = "Hello World"
        @State private var textSmall = "Compact Mode"
        @State private var textPassword = "SecretPassword123"
        
        var body: some View {
            VStack(spacing: 25) {
                Text("UMUITextField Previews")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Standard Text Fields")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    UMUITextField(
                        label: "Username",
                        placeholder: "Enter username...",
                        value: $textNormal,
                        size: .normal
                    )
                    
                    UMUITextField(
                        label: "Tags",
                        placeholder: "Enter tags...",
                        value: $textSmall,
                        size: .small
                    )
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Secure Password with Eye Toggle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    UMUITextField(
                        label: "Password",
                        placeholder: "Enter password...",
                        value: $textPassword,
                        size: .normal,
                        isSecure: true
                    )
                }
                
                Divider()
                
                // Debugging values to demonstrate 0.3s debounce and Enter commit
                VStack(alignment: .leading, spacing: 10) {
                    Text("🔍 Real-time Debounce Debugger")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Binding Value (syncs on Enter or 0.3s delay):")
                                .font(.caption2)
                                .bold()
                            Spacer()
                        }
                        Text("\"\(textNormal)\"")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
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
