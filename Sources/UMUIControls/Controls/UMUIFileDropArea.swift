//
//  UMUIFileDropArea.swift
//  UMUIControls
//
//  A UMUIDropArea that handles the drop itself: it accepts one file (optionally
//  restricted to some extensions) or one folder, opens an open panel on click,
//  shows the chosen item's name and can clear it.
//

import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

/// What a `UMUIFileDropArea` accepts.
@available(macOS 11.0, *)
public enum UMUIFileDropKind: Sendable, Equatable {
    /// A single file; an empty list accepts any extension.
    case file(extensions: [String])
    /// A single folder.
    case folder
}

/// A drop target bound to an optional URL.
///
/// Dropping an item of the wrong kind is refused (the area does not light up
/// as a valid target for it). Clicking the area opens an `NSOpenPanel` set up
/// for the same kind.
///
/// Usage:
/// ```swift
/// UMUIFileDropArea(url: $customTitleURL, kind: .file(extensions: ["moti"]), prompt: "Drag a Motion title here")
/// UMUIFileDropArea(url: $destinationFolder, kind: .folder, prompt: "Drag a folder here")
/// ```
@available(macOS 12.0, *)
public struct UMUIFileDropArea: View {
    /// The bound URL, `nil` when nothing is chosen.
    @Binding public var url: URL?

    /// What the area accepts.
    public let kind: UMUIFileDropKind

    /// The text shown while nothing is chosen.
    public let prompt: String

    /// Optional small bold title above the area (see `UMUIDropArea`).
    public let title: String

    /// SF Symbol shown in the area; defaults to a document or a folder.
    public let icon: String?

    /// Whether a clear button appears while a URL is set.
    public let isClearable: Bool

    @State private var isTargeted = false

    /// Creates a file / folder drop area.
    public init(
        url: Binding<URL?>,
        kind: UMUIFileDropKind = .file(extensions: []),
        prompt: String = "Drop here or click to choose",
        title: String = "",
        icon: String? = nil,
        isClearable: Bool = true
    ) {
        self._url = url
        self.kind = kind
        self.prompt = prompt
        self.title = title
        self.icon = icon
        self.isClearable = isClearable
    }

    public var body: some View {
        UMUIDropArea(title: title,
                     subtitle: url?.lastPathComponent,
                     icon: icon ?? defaultIcon,
                     isTargeted: isTargeted,
                     placeholder: prompt,
                     onSelect: choose)
            .overlay(alignment: .topTrailing) {
                if isClearable && url != nil {
                    Button {
                        url = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Clear")
                    .padding(6)
                }
            }
            .help(url?.path ?? prompt)
            .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
                drop(providers)
            }
    }

    private var defaultIcon: String {
        switch kind {
        case .file:
            return "doc.badge.plus"
        case .folder:
            return "folder.badge.plus"
        }
    }

    /// Whether `candidate` is the kind of item this area takes.
    private func accepts(_ candidate: URL) -> Bool {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: candidate.path, isDirectory: &isDirectory) else {
            return false
        }
        switch kind {
        case .folder:
            return isDirectory.boolValue
        case .file(let extensions):
            // A package such as a Motion template is a directory, so only the
            // extension decides when one is given.
            if extensions.isEmpty {
                return !isDirectory.boolValue
            }
            return extensions.contains { $0.caseInsensitiveCompare(candidate.pathExtension) == .orderedSame }
        }
    }

    private func drop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else {
            return false
        }
        _ = provider.loadObject(ofClass: URL.self) { dropped, _ in
            guard let dropped = dropped, accepts(dropped) else { return }
            DispatchQueue.main.async {
                url = dropped
            }
        }
        return true
    }

    private func choose() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = kind == .folder
        switch kind {
        case .folder:
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
        case .file(let extensions):
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            let types = extensions.compactMap { UTType(filenameExtension: $0) }
            if !types.isEmpty {
                panel.allowedContentTypes = types
            }
            // Packages (a .moti template) are chosen as files.
            panel.treatsFilePackagesAsDirectories = false
        }
        if let current = url {
            panel.directoryURL = current.deletingLastPathComponent()
        }
        if panel.runModal() == .OK, let chosen = panel.url, accepts(chosen) {
            url = chosen
        }
        #endif
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct UMUIFileDropArea_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var file: URL? = nil
        @State private var folder: URL? = URL(fileURLWithPath: NSHomeDirectory())

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                UMUIFileDropArea(url: $file, kind: .file(extensions: ["moti"]), prompt: "Drag a Motion title here")
                UMUIFileDropArea(url: $folder, kind: .folder, prompt: "Drag a folder here")
            }
            .padding(20)
            .frame(width: 320)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
