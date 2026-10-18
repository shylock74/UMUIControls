//
//  UMUISettingsGlobalView.swift
//  UMUIControls
//
//  A comprehensive multi-pane settings component styled for macOS.
//  Provides sidebar navigation on the left and dynamic content container on the right.
//

import SwiftUI

/// A container holding metadata and a view for a single settings pane.
@available(macOS 11.0, *)
public struct UMUISettingPaneView: Identifiable {
    public let id: String
    public let icon: String
    public let name: String
    private let makeContent: () -> AnyView
    /// Shows a small accent dot next to the name in the sidebar.
    public let badge: Bool

    /// The pane's view. Built each time it is read, so only the selected pane is ever built.
    public var content: AnyView { makeContent() }
    
    /// Creates a settings pane.
    /// - Parameters:
    ///   - id: An optional unique identifier. If nil, the name will be used as the identifier.
    ///   - icon: The SF Symbol name to display in the sidebar.
    ///   - name: The human-readable name of the pane.
    ///   - content: A `@ViewBuilder` providing the visual content for this pane.
    public init<Content: View>(
        id: String? = nil,
        icon: String,
        name: String,
        badge: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id ?? name
        self.icon = icon
        self.name = name
        self.badge = badge
        self.makeContent = { AnyView(content()) }
    }

    /// Backward-compatibility initializer for clients built against earlier versions of UMUIControls.
    public init<Content: View>(
        id: String? = nil,
        icon: String,
        name: String,
        @ViewBuilder content: () -> Content
    ) {
        let view = content()
        self.id = id ?? name
        self.icon = icon
        self.name = name
        self.badge = false
        self.makeContent = { AnyView(view) }
    }
}

/// A result builder to collect individual settings panes.
@available(macOS 11.0, *)
@resultBuilder
public struct UMUISettingPaneViewBuilder {
    public static func buildExpression(_ expression: UMUISettingPaneView) -> [UMUISettingPaneView] {
        [expression]
    }

    public static func buildExpression(_ expression: [UMUISettingPaneView]) -> [UMUISettingPaneView] {
        expression
    }

    public static func buildBlock(_ components: [UMUISettingPaneView]...) -> [UMUISettingPaneView] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [UMUISettingPaneView]?) -> [UMUISettingPaneView] {
        component ?? []
    }

    public static func buildEither(first component: [UMUISettingPaneView]) -> [UMUISettingPaneView] {
        component
    }

    public static func buildEither(second component: [UMUISettingPaneView]) -> [UMUISettingPaneView] {
        component
    }

    public static func buildArray(_ components: [[UMUISettingPaneView]]) -> [UMUISettingPaneView] {
        components.flatMap { $0 }
    }
}

/// Look of the settings container.
@available(macOS 11.0, *)
public enum UMUISettingsChrome: Sendable {
    /// Outer padding, rounded border and a boxed content area (the original look).
    case bordered
    /// No outer border or box: the container fills whatever hosts it (e.g. a sheet).
    case plain
}

/// A macOS-styled settings view container featuring a left navigation sidebar and a right content container.
///
/// Features:
/// - Support for custom SF Symbols and text in the sidebar.
/// - Dynamic selection state mapping system accent colors/tints.
/// - Automatic state persistence across runs via `@AppStorage`.
/// - Supports both automatic persistence or external `@State` tracking using a custom binding.
///
/// Usage with automatic persistence:
/// ```swift
/// UMUISettingsGlobalView(storageKey: "myAppSelectedPane") {
///     UMUISettingPaneView(icon: "gearshape", name: "General") {
///         GeneralSettings()
///     }
///     UMUISettingPaneView(icon: "bell", name: "Notifications") {
///         NotificationSettings()
///     }
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUISettingsGlobalView: View {
    public let panes: [UMUISettingPaneView]
    public let accentColor: Color?
    /// Width of the sidebar (default 180).
    public let sidebarWidth: CGFloat
    /// `.plain` drops the outer border and the content box.
    public let chrome: UMUISettingsChrome
    /// Shows the selected pane's name above its content (default `true`).
    public let showsPaneTitle: Bool
    
    // Internal state wrapper for AppStorage persistence
    @AppStorage
    private var selectedPaneState: String
    
    // External binding option
    private let selectedPaneBinding: Binding<String>?
    private let defaultPaneId: String
    
    @Environment(\.umAccentColor) private var envAccentColor
    
    private var resolvedAccentColor: Color {
        accentColor ?? envAccentColor ?? .accentColor
    }
    
    /// Initializes the settings view with a custom binding to control and persist the selection externally.
    /// - Parameters:
    ///   - selectedPane: A binding to the currently selected pane ID.
    ///   - accentColor: An optional custom accent color. Defaults to the system or environment accent color.
    ///   - panes: A `@ViewBuilder` returning a list of `UMUISettingPaneView` objects.
    public init(
        selectedPane: Binding<String>,
        accentColor: Color? = nil,
        sidebarWidth: CGFloat = 180,
        chrome: UMUISettingsChrome = .bordered,
        showsPaneTitle: Bool = true,
        @UMUISettingPaneViewBuilder panes: () -> [UMUISettingPaneView]
    ) {
        let resolvedPanes = panes()
        self.panes = resolvedPanes
        self.accentColor = accentColor
        self.sidebarWidth = sidebarWidth
        self.chrome = chrome
        self.showsPaneTitle = showsPaneTitle
        self.selectedPaneBinding = selectedPane
        self.defaultPaneId = resolvedPanes.first?.id ?? ""
        self._selectedPaneState = AppStorage(wrappedValue: "", "UMUISettingsGlobalView.unusedKey")
    }

    /// Backward-compatibility initializer for clients built against earlier versions of UMUIControls.
    public init(
        selectedPane: Binding<String>,
        accentColor: Color? = nil,
        @UMUISettingPaneViewBuilder panes: () -> [UMUISettingPaneView]
    ) {
        self.init(
            selectedPane: selectedPane,
            accentColor: accentColor,
            sidebarWidth: 180,
            chrome: .bordered,
            showsPaneTitle: true,
            panes: panes
        )
    }
    
    /// Initializes the settings view with automatic internal persistence.
    /// - Parameters:
    ///   - storageKey: The UserDefaults key name to store the selected pane state. Defaults to `"UMUIControls.Settings.selectedPane"`.
    ///   - accentColor: An optional custom accent color. Defaults to the system or environment accent color.
    ///   - panes: A `@ViewBuilder` returning a list of `UMUISettingPaneView` objects.
    public init(
        storageKey: String = "UMUIControls.Settings.selectedPane",
        accentColor: Color? = nil,
        sidebarWidth: CGFloat = 180,
        chrome: UMUISettingsChrome = .bordered,
        showsPaneTitle: Bool = true,
        @UMUISettingPaneViewBuilder panes: () -> [UMUISettingPaneView]
    ) {
        let resolvedPanes = panes()
        self.panes = resolvedPanes
        self.accentColor = accentColor
        self.sidebarWidth = sidebarWidth
        self.chrome = chrome
        self.showsPaneTitle = showsPaneTitle
        self.selectedPaneBinding = nil
        let firstId = resolvedPanes.first?.id ?? ""
        self.defaultPaneId = firstId
        self._selectedPaneState = AppStorage(wrappedValue: firstId, storageKey)
    }

    /// Backward-compatibility initializer for clients built against earlier versions of UMUIControls.
    public init(
        storageKey: String = "UMUIControls.Settings.selectedPane",
        accentColor: Color? = nil,
        @UMUISettingPaneViewBuilder panes: () -> [UMUISettingPaneView]
    ) {
        self.init(
            storageKey: storageKey,
            accentColor: accentColor,
            sidebarWidth: 180,
            chrome: .bordered,
            showsPaneTitle: true,
            panes: panes
        )
    }
    
    private var currentSelection: String {
        let raw: String
        if let binding = selectedPaneBinding {
            raw = binding.wrappedValue
        } else {
            raw = selectedPaneState.isEmpty ? defaultPaneId : selectedPaneState
        }
        // A selection that points at a pane that is not there (e.g. hidden) falls back to the first.
        return panes.contains(where: { $0.id == raw }) ? raw : (panes.first?.id ?? raw)
    }
    
    private func selectPane(_ id: String) {
        if let binding = selectedPaneBinding {
            binding.wrappedValue = id
        } else {
            selectedPaneState = id
        }
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: chrome == .bordered ? 12 : 0) {
            // Sidebar: Left navigation area
            VStack(alignment: .leading, spacing: 6) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(panes) { pane in
                            SidebarButton(
                                pane: pane,
                                isSelected: currentSelection == pane.id,
                                accentColor: resolvedAccentColor,
                                action: { selectPane(pane.id) }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .frame(width: sidebarWidth)
            
            // Content Area: Right side pane content
            if let activePane = panes.first(where: { $0.id == currentSelection }) ?? panes.first {
                VStack(alignment: .leading, spacing: 8) {
                    // Header displaying active category name
                    if showsPaneTitle {
                        Text(activePane.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.leading, 4)
                    }
                    
                    // Main content viewport with standard framing
                    if chrome == .bordered {
                        ZStack {
                            activePane.content
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                .background(Color.darkGray.opacity(0.3))
                        )
                        .cornerRadius(8)
                    } else {
                        activePane.content
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
            } else {
                VStack {
                    Spacer()
                    Text("No Pane Configured")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .modifier(UMUISettingsChromeModifier(chrome: chrome))
    }
}

@available(macOS 11.0, *)
private struct UMUISettingsChromeModifier: ViewModifier {
    let chrome: UMUISettingsChrome

    func body(content: Content) -> some View {
        if chrome == .bordered {
            content
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        .background(Color.darkGray.opacity(0.15))
                )
                .cornerRadius(12)
        } else {
            content
        }
    }
}

/// A compact navigation button styled for the settings sidebar.
@available(macOS 11.0, *)
private struct SidebarButton: View {
    let pane: UMUISettingPaneView
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    @State private var isHovering = false
    @Environment(\.self) private var environment
    
    private var isLightAccent: Bool {
        accentColor.umIsLight(in: environment)
    }
    
    private var selectedForeground: Color {
        accentColor.umContrastingTextColor(in: environment)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // SF Symbol icon centered in a rounded container box
                Image(systemName: pane.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isSelected ? (isLightAccent ? Color.darkGray.opacity(0.12) : Color.white.opacity(0.2)) : Color.secondary.opacity(0.15))
                    )
                    .foregroundColor(isSelected ? selectedForeground : .primary)
                
                Text(pane.name)
                    .font(.body)
                    .fontWeight(isSelected ? .medium : .regular)
                    .foregroundColor(isSelected ? selectedForeground : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isSelected
                    ? accentColor
                    : (isHovering ? Color.secondary.opacity(0.1) : Color.clear)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected
                    ? accentColor.opacity(0.8)
                    : Color.secondary.opacity(0.2),
                    lineWidth: 1
                )
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

@available(macOS 11.0, *)
public extension UMUISettingsGlobalView {
    /// Sets the accent color for this settings view and its sidebar navigation buttons.
    func accentColor(_ color: Color) -> some View {
        self.umAccentColor(color)
    }
}

// Supporting typo class definition requested in instructions for safety/compatibility.
@available(macOS 11.0, *)
public typealias UMUISettingsGloablView = UMUISettingsGlobalView

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUISettingsGlobalView_Previews: PreviewProvider {
    static var previews: some View {
        UMUISettingsGlobalView(storageKey: "previewSelectedPane") {
            UMUISettingPaneView(id: "transcription", icon: "waveform", name: "Transcription") {
                Text("Transcription Content")
            }
            UMUISettingPaneView(id: "ai", icon: "wand.and.sparkles", name: "AI & Translation") {
                Text("AI & Translation Content")
            }
            UMUISettingPaneView(id: "export", icon: "square.and.arrow.up", name: "Export & Subtitles") {
                Text("Export Content")
            }
            UMUISettingPaneView(id: "editor", icon: "slider.horizontal.3", name: "Editor & Player") {
                Text("Editor Content")
            }
            UMUISettingPaneView(id: "advanced", icon: "gearshape", name: "Advanced & System") {
                Text("Advanced Content")
            }
        }
        .accentColor(.cyan)
        .frame(width: 550, height: 360)
        .preferredColorScheme(.dark)
    }
}
#endif
