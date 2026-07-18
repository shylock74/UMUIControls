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
    public let content: AnyView
    
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
        @ViewBuilder content: () -> Content
    ) {
        self.id = id ?? name
        self.icon = icon
        self.name = name
        self.content = AnyView(content())
    }
}

/// A result builder to collect individual settings panes.
@available(macOS 11.0, *)
@resultBuilder
public struct UMUISettingPaneViewBuilder {
    public static func buildBlock(_ components: UMUISettingPaneView...) -> [UMUISettingPaneView] {
        components
    }
    public static func buildBlock(_ components: [UMUISettingPaneView]) -> [UMUISettingPaneView] {
        components
    }
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
    
    // Internal state wrapper for AppStorage persistence
    @AppStorage
    private var selectedPaneState: String
    
    // External binding option
    private let selectedPaneBinding: Binding<String>?
    private let defaultPaneId: String
    
    /// Initializes the settings view with a custom binding to control and persist the selection externally.
    /// - Parameters:
    ///   - selectedPane: A binding to the currently selected pane ID.
    ///   - panes: A `@ViewBuilder` returning a list of `UMUISettingPaneView` objects.
    public init(
        selectedPane: Binding<String>,
        @UMUISettingPaneViewBuilder panes: () -> [UMUISettingPaneView]
    ) {
        let resolvedPanes = panes()
        self.panes = resolvedPanes
        self.selectedPaneBinding = selectedPane
        self.defaultPaneId = resolvedPanes.first?.id ?? ""
        self._selectedPaneState = AppStorage(wrappedValue: "", "UMUISettingsGlobalView.unusedKey")
    }
    
    /// Initializes the settings view with automatic internal persistence.
    /// - Parameters:
    ///   - storageKey: The UserDefaults key name to store the selected pane state. Defaults to `"UMUIControls.Settings.selectedPane"`.
    ///   - panes: A `@ViewBuilder` returning a list of `UMUISettingPaneView` objects.
    public init(
        storageKey: String = "UMUIControls.Settings.selectedPane",
        @UMUISettingPaneViewBuilder panes: () -> [UMUISettingPaneView]
    ) {
        let resolvedPanes = panes()
        self.panes = resolvedPanes
        self.selectedPaneBinding = nil
        let firstId = resolvedPanes.first?.id ?? ""
        self.defaultPaneId = firstId
        self._selectedPaneState = AppStorage(wrappedValue: firstId, storageKey)
    }
    
    private var currentSelection: String {
        if let binding = selectedPaneBinding {
            return binding.wrappedValue
        }
        return selectedPaneState.isEmpty ? defaultPaneId : selectedPaneState
    }
    
    private func selectPane(_ id: String) {
        if let binding = selectedPaneBinding {
            binding.wrappedValue = id
        } else {
            selectedPaneState = id
        }
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Sidebar: Left navigation area
            VStack(alignment: .leading, spacing: 6) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(panes) { pane in
                            SidebarButton(
                                pane: pane,
                                isSelected: currentSelection == pane.id,
                                action: { selectPane(pane.id) }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .frame(width: 180)
            
            // Content Area: Right side pane content
            if let activePane = panes.first(where: { $0.id == currentSelection }) ?? panes.first {
                VStack(alignment: .leading, spacing: 8) {
                    // Header displaying active category name
                    Text(activePane.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.leading, 4)
                    
                    // Main content viewport with standard framing
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                .background(Color.darkGray.opacity(0.15))
        )
        .cornerRadius(12)
    }
}

/// A compact navigation button styled for the settings sidebar.
@available(macOS 11.0, *)
private struct SidebarButton: View {
    let pane: UMUISettingPaneView
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // SF Symbol icon centered in a rounded container box
                Image(systemName: pane.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isSelected ? Color.white.opacity(0.2) : Color.secondary.opacity(0.15))
                    )
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(pane.name)
                    .font(.body)
                    .fontWeight(isSelected ? .medium : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
                
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
                    ? Color.accentColor
                    : (isHovering ? Color.secondary.opacity(0.1) : Color.clear)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected
                    ? Color.accentColor.opacity(0.8)
                    : Color.secondary.opacity(0.2),
                    lineWidth: 1
                )
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// Supporting typo class definition requested in instructions for safety/compatibility.
@available(macOS 11.0, *)
public typealias UMUISettingsGloablView = UMUISettingsGlobalView
