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
@available(macOS 11.0, *)
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
@available(macOS 11.0, *)
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
    
    /// Creates a new premium text field.
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
        if #available(macOS 12.0, *) {
            UMUITextFieldModern(
                label: label,
                placeholder: placeholder,
                value: $value,
                size: size,
                isSecure: isSecure,
                labelWidth: labelWidth
            )
        } else {
            UMUITextFieldLegacy(
                label: label,
                placeholder: placeholder,
                value: $value,
                size: size,
                isSecure: isSecure,
                labelWidth: labelWidth
            )
        }
    }
}

/// The modern implementation of UMUITextField using modern FocusState.
@available(macOS 12.0, *)
struct UMUITextFieldModern: View {
    public let label: String?
    public let placeholder: String
    @Binding public var value: String
    public let size: UMUITextFieldSize
    public let isSecure: Bool
    public let labelWidth: CGFloat
    
    @State private var localText: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var debouncer = TextFieldDebouncer()
    @FocusState private var isFocused: Bool
    
    public init(
        label: String?,
        placeholder: String,
        value: Binding<String>,
        size: UMUITextFieldSize,
        isSecure: Bool,
        labelWidth: CGFloat
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
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(labelFont)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }
            
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
                
                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                        isFocused = true
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(size == .small ? .caption2 : .body)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                }
            }
            .padding(.horizontal, size == .small ? 8 : 10)
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
    
    private func startDebounce() {
        let currentText = localText
        debouncer.debounce(delay: 0.3) {
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
}

/// The legacy implementation of UMUITextField supporting macOS 11 without FocusState.
@available(macOS 11.0, *)
struct UMUITextFieldLegacy: View {
    public let label: String?
    public let placeholder: String
    @Binding public var value: String
    public let size: UMUITextFieldSize
    public let isSecure: Bool
    public let labelWidth: CGFloat
    
    @State private var localText: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var debouncer = TextFieldDebouncer()
    @State private var isFocused: Bool = false
    
    public init(
        label: String?,
        placeholder: String,
        value: Binding<String>,
        size: UMUITextFieldSize,
        isSecure: Bool,
        labelWidth: CGFloat
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
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(labelFont)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }
            
            HStack(spacing: 4) {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $localText, onCommit: { commitChanges() })
                        .textFieldStyle(.plain)
                        .font(fieldFont)
                } else {
                    TextField(placeholder, text: $localText, onEditingChanged: { editing in
                        isFocused = editing
                    }, onCommit: {
                        commitChanges()
                    })
                    .textFieldStyle(.plain)
                    .font(fieldFont)
                }
                
                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(size == .small ? .caption2 : .body)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                }
            }
            .padding(.horizontal, size == .small ? 8 : 10)
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
        .onDisappear {
            commitChanges()
        }
    }
    
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
    
    private func startDebounce() {
        let currentText = localText
        debouncer.debounce(delay: 0.3) {
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
}

// MARK: - Debouncer Engine

/// A thread-safe, background-managed debouncer that isolates delay-timers and state checks from the Main Actor.
private final class TextFieldDebouncer {
    private var workItem: DispatchWorkItem?
    
    func debounce(delay: Double, action: @escaping () -> Void) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        
        // Execute the delay timer safely on the Main Queue
        DispatchQueue.main.asyncAfter(
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
@available(macOS 11.0, *)
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
                        .foregroundColor(.secondary)
                    
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
                        .foregroundColor(.secondary)
                    
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
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Binding Value (syncs on Enter or 0.3s delay):")
                                .font(.caption2)
                                .bold()
                            Spacer()
                        }
                        Text("\"\(textNormal)\"")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(Color.accentColor)
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
