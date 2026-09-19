//
//  UMUIThreeColumnSplitView.swift
//  UMUIControls
//
//  A resizable sidebar / content / inspector layout for document windows, with
//  collapsible side columns bound to the caller's state.
//

import SwiftUI

/// Width limits of one side column of `UMUIThreeColumnSplitView`.
@available(macOS 11.0, *)
public struct UMUIColumnWidth: Sendable, Equatable {
    public var min: CGFloat
    public var ideal: CGFloat
    public var max: CGFloat

    public init(min: CGFloat, ideal: CGFloat, max: CGFloat) {
        self.min = min
        self.ideal = ideal
        self.max = max
    }

    /// 220 / 280 / 400: a navigation sidebar.
    public static let sidebar = UMUIColumnWidth(min: 220, ideal: 280, max: 400)

    /// 260 / 340 / 520: an inspector with a preview canvas.
    public static let inspector = UMUIColumnWidth(min: 260, ideal: 340, max: 520)
}

/// A three-column split view: leading sidebar, central content, trailing inspector.
///
/// The dividers are the native AppKit ones (drag to resize); the side columns
/// collapse when their visibility binding turns `false`. The central column
/// always takes the remaining space and never goes below `contentMinWidth`.
///
/// Usage:
/// ```swift
/// UMUIThreeColumnSplitView(showSidebar: $showSidebar, showInspector: $showInspector) {
///     SidebarView()
/// } content: {
///     WorkspaceView()
/// } inspector: {
///     InspectorView()
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIThreeColumnSplitView<Sidebar: View, Content: View, Inspector: View>: View {
    @Binding public var showSidebar: Bool
    @Binding public var showInspector: Bool

    public let sidebarWidth: UMUIColumnWidth
    public let inspectorWidth: UMUIColumnWidth
    public let contentMinWidth: CGFloat

    public let sidebar: Sidebar
    public let content: Content
    public let inspector: Inspector

    public init(
        showSidebar: Binding<Bool> = .constant(true),
        showInspector: Binding<Bool> = .constant(true),
        sidebarWidth: UMUIColumnWidth = .sidebar,
        inspectorWidth: UMUIColumnWidth = .inspector,
        contentMinWidth: CGFloat = 420,
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder inspector: () -> Inspector
    ) {
        self._showSidebar = showSidebar
        self._showInspector = showInspector
        self.sidebarWidth = sidebarWidth
        self.inspectorWidth = inspectorWidth
        self.contentMinWidth = contentMinWidth
        self.sidebar = sidebar()
        self.content = content()
        self.inspector = inspector()
    }

    public var body: some View {
        HSplitView {
            if showSidebar {
                sidebar
                    .frame(minWidth: sidebarWidth.min, idealWidth: sidebarWidth.ideal, maxWidth: sidebarWidth.max, maxHeight: .infinity)
                    .background(Color(.windowBackgroundColor))
            }

            content
                .frame(minWidth: contentMinWidth, maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(1)

            if showInspector {
                inspector
                    .frame(minWidth: inspectorWidth.min, idealWidth: inspectorWidth.ideal, maxWidth: inspectorWidth.max, maxHeight: .infinity)
                    .background(Color(.windowBackgroundColor))
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIThreeColumnSplitView_Previews: PreviewProvider {
    static var previews: some View {
        UMUIThreeColumnSplitView {
            Text("Sidebar").frame(maxWidth: .infinity, maxHeight: .infinity)
        } content: {
            Text("Content").frame(maxWidth: .infinity, maxHeight: .infinity)
        } inspector: {
            Text("Inspector").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 1100, height: 600)
    }
}
#endif
