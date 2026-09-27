//
//  UMUIWindow.swift
//  UMUIControls
//
//  Opens a SwiftUI view in its own window, one window per id: asking again for
//  an id that is already open brings that window to the front instead of
//  stacking a copy.
//

#if os(macOS)
import SwiftUI
import AppKit

/// Standalone windows hosting SwiftUI content.
///
/// Usage:
/// ```swift
/// UMUIWindow.show(id: "app.dictionaries", title: "Dictionaries") {
///     DictionaryManagerView()
///         .environmentObject(config)
/// }
/// ```
@available(macOS 11.0, *)
public enum UMUIWindow {

    /// Open windows by id. Main-thread only, like the windows themselves.
    private static var controllers: [String: NSWindowController] = [:]

    /// Shows `content` in the window registered under `id`, creating it if needed.
    /// - Parameters:
    ///   - id: Identifies the window; `nil` always opens a new one.
    ///   - title: The window title.
    ///   - resizable: Whether the user can resize the window.
    ///   - floating: Whether the window stays above the others.
    ///   - content: The SwiftUI root view.
    public static func show<Content: View>(
        id: String? = nil,
        title: String,
        resizable: Bool = true,
        floating: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        let rootView = content()
        let present = {
            let key = id ?? UUID().uuidString
            if let existing = controllers[key], let window = existing.window {
                window.title = title
                window.contentViewController = NSHostingController(rootView: rootView)
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                return
            }

            var style: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
            if resizable {
                style.insert(.resizable)
            }
            let window = NSWindow(contentViewController: NSHostingController(rootView: rootView))
            window.styleMask = style
            window.title = title
            window.isReleasedWhenClosed = false
            window.level = floating ? .floating : .normal
            window.center()

            let controller = NSWindowController(window: window)
            controllers[key] = controller

            // Forget the controller once its window closes, so the next show builds a fresh one.
            var observer: NSObjectProtocol?
            observer = NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification,
                                                              object: window,
                                                              queue: .main) { _ in
                controllers[key] = nil
                if let observer = observer {
                    NotificationCenter.default.removeObserver(observer)
                }
            }

            controller.showWindow(nil)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }

        if Thread.isMainThread {
            present()
        } else {
            DispatchQueue.main.async(execute: present)
        }
    }

    /// Closes the window registered under `id`, if open.
    public static func close(id: String) {
        let dismiss = {
            controllers[id]?.close()
            controllers[id] = nil
        }
        if Thread.isMainThread {
            dismiss()
        } else {
            DispatchQueue.main.async(execute: dismiss)
        }
    }
}
#endif
