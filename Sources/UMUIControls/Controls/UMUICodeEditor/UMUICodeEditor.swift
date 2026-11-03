//
//  UMUICodeEditor.swift
//  UMUIControls
//
//  A monospaced code/text editor backed by a TextKit 1 NSTextView: line
//  numbers, syntax highlighting (YAML, JSON, Markdown), the real AppKit undo
//  manager, find bar, a debounced binding and an optional file-drop handler.
//
//  Programmatic replacements that must be undoable (an AI rewrite, say) go
//  through `UMUICodeEditorController.replaceAll(with:actionName:)`; changing
//  the binding from outside replaces the text without an undo step.
//

import SwiftUI
import AppKit

/// Lets the owner of a `UMUICodeEditor` act on its text view.
///
/// Usage:
/// ```swift
/// @StateObject private var editor = UMUICodeEditorController()
/// UMUICodeEditor(text: $content, language: .yaml, controller: editor)
/// Button("Convert") { editor.replaceAll(with: converted, actionName: "Convert to YAML") }
/// ```
@MainActor
public final class UMUICodeEditorController: ObservableObject {

    weak var textView: NSTextView?

    public init() {}

    /// The text currently shown, including keystrokes not yet pushed to the binding.
    public var currentText: String? {
        textView?.string
    }

    /// Replaces the whole text as one undoable step named `actionName`.
    /// Returns `false` when the editor is not on screen.
    @discardableResult
    public func replaceAll(with newText: String, actionName: String) -> Bool {
        guard let textView else { return false }
        let range = NSRange(location: 0, length: (textView.string as NSString).length)
        guard textView.shouldChangeText(in: range, replacementString: newText) else { return false }
        textView.textStorage?.replaceCharacters(in: range, with: newText)
        textView.didChangeText()
        textView.undoManager?.setActionName(actionName)
        return true
    }

    /// Gives keyboard focus to the editor.
    public func focus() {
        guard let textView else { return }
        textView.window?.makeFirstResponder(textView)
    }
}

/// A monospaced editor with line numbers and syntax highlighting.
///
/// Keystrokes edit the text view; the binding is written `debounceInterval`
/// after the last keystroke and immediately when the editor loses focus or
/// disappears.
@available(macOS 13.0, *)
public struct UMUICodeEditor: View {

    @Binding public var text: String
    public let language: UMUICodeLanguage
    public let controller: UMUICodeEditorController?
    public let fontSize: CGFloat
    public let isEditable: Bool
    public let showsLineNumbers: Bool
    public let debounceInterval: TimeInterval
    public let onDropFiles: (([URL]) -> Void)?

    public init(text: Binding<String>,
                language: UMUICodeLanguage = .plainText,
                controller: UMUICodeEditorController? = nil,
                fontSize: CGFloat = 12,
                isEditable: Bool = true,
                showsLineNumbers: Bool = true,
                debounceInterval: TimeInterval = 0.3,
                onDropFiles: (([URL]) -> Void)? = nil) {
        self._text = text
        self.language = language
        self.controller = controller
        self.fontSize = fontSize
        self.isEditable = isEditable
        self.showsLineNumbers = showsLineNumbers
        self.debounceInterval = debounceInterval
        self.onDropFiles = onDropFiles
    }

    public var body: some View {
        UMUICodeEditorRepresentable(text: $text,
                                    language: language,
                                    controller: controller,
                                    fontSize: fontSize,
                                    isEditable: isEditable,
                                    showsLineNumbers: showsLineNumbers,
                                    debounceInterval: debounceInterval,
                                    onDropFiles: onDropFiles)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
    }
}

/// NSTextView that hands dropped files to a closure instead of inserting their paths.
final class UMUICodeTextView: NSTextView {

    var onDropFiles: (([URL]) -> Void)?

    private func fileURLs(from info: NSDraggingInfo) -> [URL] {
        let options: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
        return info.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: options) as? [URL] ?? []
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if onDropFiles != nil, !fileURLs(from: sender).isEmpty { return .copy }
        return super.draggingEntered(sender)
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if onDropFiles != nil, !fileURLs(from: sender).isEmpty { return .copy }
        return super.draggingUpdated(sender)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = fileURLs(from: sender)
        if let onDropFiles, !urls.isEmpty {
            onDropFiles(urls)
            return true
        }
        return super.performDragOperation(sender)
    }
}

@available(macOS 13.0, *)
struct UMUICodeEditorRepresentable: NSViewRepresentable {

    @Binding var text: String
    let language: UMUICodeLanguage
    let controller: UMUICodeEditorController?
    let fontSize: CGFloat
    let isEditable: Bool
    let showsLineNumbers: Bool
    let debounceInterval: TimeInterval
    let onDropFiles: (([URL]) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        // Explicit TextKit 1 stack: the ruler needs the layout manager.
        let storage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        storage.addLayoutManager(layoutManager)
        let container = NSTextContainer(containerSize: NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)

        let textView = UMUICodeTextView(frame: .zero, textContainer: container)
        textView.minSize = .zero
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.smartInsertDeleteEnabled = false
        textView.textContainerInset = NSSize(width: 4, height: 6)
        textView.backgroundColor = .textBackgroundColor
        textView.drawsBackground = true
        textView.isEditable = isEditable
        textView.font = context.coordinator.font
        textView.typingAttributes = [.font: context.coordinator.font, .foregroundColor: NSColor.textColor]
        textView.onDropFiles = onDropFiles
        textView.delegate = context.coordinator
        storage.delegate = context.coordinator

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.documentView = textView

        if showsLineNumbers {
            let ruler = UMUILineNumberRulerView(textView: textView, scrollView: scrollView)
            scrollView.verticalRulerView = ruler
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
            context.coordinator.ruler = ruler
        }

        scrollView.contentView.postsBoundsChangedNotifications = true
        context.coordinator.observeScrolling(of: scrollView.contentView)

        context.coordinator.textView = textView
        context.coordinator.setTextWithoutUndo(text)
        controller?.textView = textView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        guard let textView = coordinator.textView else { return }

        controller?.textView = textView
        textView.isEditable = isEditable
        textView.onDropFiles = onDropFiles

        if coordinator.language != language || coordinator.fontSize != fontSize {
            coordinator.language = language
            coordinator.fontSize = fontSize
            textView.font = coordinator.font
            coordinator.rehighlight()
        }

        // Only an outside change of the binding replaces the text: while the
        // debounce is pending the binding lags behind the view on purpose.
        if text != coordinator.lastSyncedText {
            coordinator.setTextWithoutUndo(text)
        }
    }

    static func dismantleNSView(_ scrollView: NSScrollView, coordinator: Coordinator) {
        coordinator.flush()
        coordinator.stopObserving()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {

        var parent: UMUICodeEditorRepresentable
        weak var textView: UMUICodeTextView?
        weak var ruler: UMUILineNumberRulerView?
        var language: UMUICodeLanguage
        var fontSize: CGFloat
        var lastSyncedText: String = ""
        private var pendingWrite: DispatchWorkItem?
        private var scrollObserver: NSObjectProtocol?

        var font: NSFont {
            NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }

        init(_ parent: UMUICodeEditorRepresentable) {
            self.parent = parent
            self.language = parent.language
            self.fontSize = parent.fontSize
        }

        func observeScrolling(of clipView: NSClipView) {
            scrollObserver = NotificationCenter.default.addObserver(
                forName: NSView.boundsDidChangeNotification,
                object: clipView,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.ruler?.needsDisplay = true
                }
            }
        }

        func stopObserving() {
            if let scrollObserver {
                NotificationCenter.default.removeObserver(scrollObserver)
            }
            scrollObserver = nil
        }

        func setTextWithoutUndo(_ newText: String) {
            guard let textView else { return }
            lastSyncedText = newText
            guard textView.string != newText else { return }
            let selection = textView.selectedRanges
            textView.undoManager?.disableUndoRegistration()
            textView.string = newText
            textView.undoManager?.enableUndoRegistration()
            rehighlight()
            let length = (newText as NSString).length
            let clamped = selection.compactMap { value -> NSValue? in
                let r = value.rangeValue
                guard r.location <= length else { return nil }
                return NSValue(range: NSRange(location: r.location, length: min(r.length, length - r.location)))
            }
            if !clamped.isEmpty {
                textView.selectedRanges = clamped
            }
        }

        func rehighlight() {
            guard let storage = textView?.textStorage else { return }
            UMUICodeHighlighter.apply(to: storage, language: language, font: font)
            ruler?.updateThickness()
            ruler?.needsDisplay = true
        }

        // MARK: NSTextStorageDelegate

        nonisolated func textStorage(_ textStorage: NSTextStorage,
                                     didProcessEditing editedMask: NSTextStorageEditActions,
                                     range editedRange: NSRange,
                                     changeInLength delta: Int) {
            guard editedMask.contains(.editedCharacters) else { return }
            MainActor.assumeIsolated {
                // Recolour after the edit is committed: attribute changes are
                // not allowed while the storage is still processing it.
                let language = self.language
                let font = self.font
                DispatchQueue.main.async { [weak self] in
                    MainActor.assumeIsolated {
                        guard let storage = self?.textView?.textStorage else { return }
                        let full = NSRange(location: 0, length: storage.length)
                        let range = NSIntersectionRange(editedRange, full)
                        UMUICodeHighlighter.apply(to: storage, language: language, font: font,
                                                  range: range.length > 0 || range.location < storage.length ? range : nil)
                    }
                }
            }
        }

        // MARK: NSTextViewDelegate

        func textDidChange(_ notification: Notification) {
            ruler?.updateThickness()
            ruler?.needsDisplay = true
            scheduleWrite()
        }

        func textDidEndEditing(_ notification: Notification) {
            flush()
        }

        private func scheduleWrite() {
            pendingWrite?.cancel()
            guard parent.debounceInterval > 0 else {
                flush()
                return
            }
            let work = DispatchWorkItem { [weak self] in
                MainActor.assumeIsolated {
                    self?.flush()
                }
            }
            pendingWrite = work
            DispatchQueue.main.asyncAfter(deadline: .now() + parent.debounceInterval, execute: work)
        }

        func flush() {
            pendingWrite?.cancel()
            pendingWrite = nil
            guard let textView else { return }
            let current = textView.string
            guard current != lastSyncedText else { return }
            lastSyncedText = current
            parent.text = current
        }
    }
}
