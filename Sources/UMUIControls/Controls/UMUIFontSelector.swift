//
//  UMUIFontSelector.swift
//  UMUIControls
//
//  Font family (searchable), optional face and optional size, stacked in the
//  usual label column. Families and faces come from NSFontManager.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

/// A font chooser: a searchable family list, then the family's faces and a size
/// control when their bindings are supplied.
///
/// Changing the family moves the face to the new family's first face whenever
/// the old one does not exist there, so the pair never names a missing font.
///
/// Usage:
/// ```swift
/// UMUIFontSelector(family: $font.family, face: $font.face, size: $font.size.umDouble, sizeRange: 10...200)
/// UMUIFontSelector(family: $font.family, size: $font.size.umDouble)   // no face row
/// ```
@available(macOS 12.0, *)
public struct UMUIFontSelector: View {
    /// The bound font family name.
    @Binding public var family: String

    /// The bound face name, or `nil` to hide the face row.
    public let face: Binding<String>?

    /// The bound point size, or `nil` to hide the size row.
    public let size: Binding<Double>?

    /// The range offered by the size control.
    public let sizeRange: ClosedRange<Double>

    /// Label of the family row.
    public let label: String

    /// Minimum width of the label column; a longer label widens it instead of being truncated.
    public let labelWidth: CGFloat

    /// Creates a font selector.
    public init(
        label: String = "Font",
        family: Binding<String>,
        face: Binding<String>? = nil,
        size: Binding<Double>? = nil,
        sizeRange: ClosedRange<Double> = 8 ... 200,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self._family = family
        self.face = face
        self.size = size
        self.sizeRange = sizeRange
        self.labelWidth = labelWidth
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            UMUILabeledRow(label, labelWidth: labelWidth) {
                UMUISearchablePicker(items: UMUIFontCatalog.familyItems,
                                     selection: $family,
                                     searchPrompt: "Search font",
                                     popoverWidth: 260,
                                     listHeight: 320)
                    .frame(width: 220)
            }

            if let face = face {
                UMUIPicker(label: "Face",
                           options: UMUIFontCatalog.faces(of: family),
                           selection: face,
                           labelWidth: labelWidth)
            }

            if let size = size {
                UMUINumberControl(title: "Size",
                                  value: size,
                                  range: sizeRange,
                                  step: 1,
                                  unit: "pt",
                                  labelWidth: labelWidth)
            }
        }
        .onChange(of: family) { newFamily in
            guard let face = face else { return }
            let faces = UMUIFontCatalog.faces(of: newFamily)
            if !faces.contains(face.wrappedValue) {
                face.wrappedValue = faces.first ?? ""
            }
        }
    }
}

// MARK: - Font catalog

/// The installed font families and their faces, read once from `NSFontManager`.
@available(macOS 12.0, *)
public enum UMUIFontCatalog {
    /// Every installed family, in the order `NSFontManager` returns them.
    public static let families: [String] = {
        #if os(macOS)
        return NSFontManager.shared.availableFontFamilies
        #else
        return []
        #endif
    }()

    /// The families as searchable picker rows.
    static let familyItems: [UMUISearchablePickerItem] = families.map {
        UMUISearchablePickerItem(id: $0, title: $0)
    }

    private static var facesCache: [String: [String]] = [:]

    /// The face names of a family ("Regular", "Bold", ...), cached per family.
    public static func faces(of family: String) -> [String] {
        if let cached = facesCache[family] {
            return cached
        }
        #if os(macOS)
        let members = NSFontManager.shared.availableMembers(ofFontFamily: family) ?? []
        let faces = members.compactMap { $0.count > 1 ? $0[1] as? String : nil }
        #else
        let faces: [String] = []
        #endif
        facesCache[family] = faces
        return faces
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct UMUIFontSelector_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var family = "Helvetica"
        @State private var face = "Regular"
        @State private var size = 54.0

        var body: some View {
            UMUIFontSelector(family: $family, face: $face, size: $size, sizeRange: 10 ... 200)
                .padding(20)
                .frame(width: 380)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
