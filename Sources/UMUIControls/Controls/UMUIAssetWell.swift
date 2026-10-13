//
//  UMUIAssetWell.swift
//  UMUIControls
//
//  A compact well for one file or image: drop a file on it, or click to choose one.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Size of an `UMUIAssetWell`.
@available(macOS 11.0, *)
public enum UMUIAssetWellSize: Sendable, Equatable {
    case small
    case medium
    case custom(CGSize)

    public var size: CGSize {
        switch self {
        case .small:          return CGSize(width: 64, height: 40)
        case .medium:         return CGSize(width: 128, height: 76)
        case .custom(let s):  return s
        }
    }
}

/// A drop target that shows a thumbnail (or an icon and the file name) of its asset.
///
/// The well does not own the asset: it reports dropped or chosen file URLs through `onDrop`
/// and removal through `onRemove`. Click chooses a file; the context menu offers
/// Choose, Reveal in Finder and Remove.
///
/// Usage:
/// ```swift
/// UMUIAssetWell(fileName: lutName, icon: "cube", size: .small, allowedTypes: [.item]) { urls in
///     lutURL = urls.first
/// } onRemove: { lutURL = nil }
/// ```
@available(macOS 11.0, *)
public struct UMUIAssetWell<Thumbnail: View>: View {

    public let fileName: String?
    public let placeholder: String
    public let icon: String
    public let size: UMUIAssetWellSize
    public let allowedTypes: [UTType]
    public let allowsMultiple: Bool
    public let revealURL: URL?
    public let onDrop: ([URL]) -> Void
    public let onRemove: (() -> Void)?
    private let thumbnail: Thumbnail?

    @State private var isTargeted = false
    @State private var isHovered = false

    public init(
        fileName: String? = nil,
        placeholder: String = "Drop or click",
        icon: String = "square.and.arrow.down",
        size: UMUIAssetWellSize = .small,
        allowedTypes: [UTType] = [.item],
        allowsMultiple: Bool = false,
        revealURL: URL? = nil,
        @ViewBuilder thumbnail: () -> Thumbnail,
        onDrop: @escaping ([URL]) -> Void,
        onRemove: (() -> Void)? = nil
    ) {
        self.fileName = fileName
        self.placeholder = placeholder
        self.icon = icon
        self.size = size
        self.allowedTypes = allowedTypes
        self.allowsMultiple = allowsMultiple
        self.revealURL = revealURL
        self.thumbnail = thumbnail()
        self.onDrop = onDrop
        self.onRemove = onRemove
    }

    private var hasAsset: Bool { fileName != nil }

    private func choose() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = allowedTypes
        panel.allowsMultipleSelection = allowsMultiple
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, !panel.urls.isEmpty { onDrop(panel.urls) }
    }

    private func handle(_ providers: [NSItemProvider]) -> Bool {
        var accepted = false
        var urls: [URL] = []
        let group = DispatchGroup()
        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            accepted = true
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                } else if let url = item as? URL {
                    urls.append(url)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            let ok = urls.filter { url in
                guard let type = UTType(filenameExtension: url.pathExtension) else { return allowedTypes.contains(.item) }
                return allowedTypes.contains { type.conforms(to: $0) }
            }
            if !ok.isEmpty { onDrop(allowsMultiple ? ok : [ok[0]]) }
        }
        return accepted
    }

    public var body: some View {
        ZStack {
            if hasAsset {
                if let thumbnail {
                    thumbnail
                        .frame(width: size.size.width, height: size.size.height)
                        .clipped()
                }
                if Thumbnail.self == EmptyView.self {
                    VStack(spacing: 2) {
                        Image(systemName: icon).font(.system(size: 14))
                        Text(fileName ?? "")
                            .font(.system(size: 9))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.horizontal, 4)
                    }
                    .foregroundColor(.primary)
                }
            } else {
                VStack(spacing: 2) {
                    Image(systemName: icon).font(.system(size: 13))
                    if size.size.height >= 60 {
                        Text(placeholder).font(.system(size: 9))
                    }
                }
                .foregroundColor(isTargeted ? .accentColor : .secondary)
            }
        }
        .frame(width: size.size.width, height: size.size.height)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isTargeted ? Color.accentColor.opacity(0.14)
                      : Color.secondary.opacity(isHovered ? 0.22 : 0.14))
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(isTargeted ? Color.accentColor : Color.clear, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            if hasAsset, isHovered, let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                }
                .buttonStyle(.plain)
                .padding(3)
            }
        }
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture { choose() }
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted, perform: handle)
        .contextMenu {
            Button("Choose…") { choose() }
            if let revealURL {
                Button("Reveal in Finder") { NSWorkspace.shared.activateFileViewerSelecting([revealURL]) }
            }
            if hasAsset, let onRemove {
                Divider()
                Button("Remove", role: .destructive, action: onRemove)
            }
        }
        .help(fileName ?? placeholder)
    }
}

@available(macOS 11.0, *)
public extension UMUIAssetWell where Thumbnail == EmptyView {
    init(
        fileName: String? = nil,
        placeholder: String = "Drop or click",
        icon: String = "square.and.arrow.down",
        size: UMUIAssetWellSize = .small,
        allowedTypes: [UTType] = [.item],
        allowsMultiple: Bool = false,
        revealURL: URL? = nil,
        onDrop: @escaping ([URL]) -> Void,
        onRemove: (() -> Void)? = nil
    ) {
        self.init(
            fileName: fileName, placeholder: placeholder, icon: icon, size: size,
            allowedTypes: allowedTypes, allowsMultiple: allowsMultiple, revealURL: revealURL,
            thumbnail: { EmptyView() }, onDrop: onDrop, onRemove: onRemove)
    }
}
