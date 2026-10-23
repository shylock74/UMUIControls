//
//  UMUIMasonryGrid.swift
//  UMUIControls
//
//  A gallery of equal-width columns where every item keeps its own proportions
//  and goes into the shortest column, so the heights even out by themselves.
//

import SwiftUI

/// The placement rules of `UMUIMasonryGrid`, apart from any view so they can be tested.
public enum UMUIMasonryLayout {

    /// The proportions (width / height) a tile may take: a panorama or a strip never gets unreadable.
    public static let aspectRatioRange: ClosedRange<CGFloat> = 0.4 ... 2.5

    /// A ratio inside `aspectRatioRange`; an unknown or invalid one counts as square.
    public static func clampedRatio(_ ratio: CGFloat?) -> CGFloat {
        guard let ratio, ratio.isFinite, ratio > 0 else { return 1 }
        return min(max(ratio, aspectRatioRange.lowerBound), aspectRatioRange.upperBound)
    }

    /// How many columns of about `columnWidth` fit `width`: at least one.
    public static func columnCount(width: CGFloat, columnWidth: CGFloat, spacing: CGFloat) -> Int {
        guard width.isFinite, columnWidth > 0 else { return 1 }
        return max(1, Int(((width + spacing) / (columnWidth + spacing)).rounded(.down)))
    }

    /// The width of each of `count` columns that fill `width`.
    public static func columnWidth(width: CGFloat, count: Int, spacing: CGFloat) -> CGFloat {
        guard count > 0, width.isFinite else { return 0 }
        return max(0, (width - spacing * CGFloat(count - 1)) / CGFloat(count))
    }

    /// The indexes of the items in each column. Items are taken in order and each goes into the
    /// shortest column; on a tie, the leftmost.
    public static func columns(ratios: [CGFloat?], count: Int, columnWidth: CGFloat, spacing: CGFloat) -> [[Int]] {
        let count = max(1, count)
        var result = [[Int]](repeating: [], count: count)
        var heights = [CGFloat](repeating: 0, count: count)
        for (index, ratio) in ratios.enumerated() {
            let column = heights.indices.min { heights[$0] < heights[$1] } ?? 0
            result[column].append(index)
            heights[column] += columnWidth / clampedRatio(ratio) + spacing
        }
        return result
    }
}

/// Lays `items` out in columns about `columnWidth` wide, filling the width it is given. The caller puts it
/// in a `ScrollView`. Each tile is sized by the grid (the column's width, the height from the ratio), so
/// `content` only draws.
@available(macOS 14.0, *)
public struct UMUIMasonryGrid<Item: Identifiable, Content: View>: View {

    private let items: [Item]
    private let columnWidth: CGFloat
    private let spacing: CGFloat
    private let aspectRatio: (Item) -> CGFloat?
    private let content: (Item) -> Content

    @State private var width: CGFloat = 0

    /// - Parameters:
    ///   - columnWidth: The width a column is meant to have; the real one fills the available width.
    ///   - spacing: Between columns and between tiles.
    ///   - aspectRatio: Width / height of an item; `nil` while unknown (shown square).
    public init(_ items: [Item],
                columnWidth: CGFloat,
                spacing: CGFloat = 8,
                aspectRatio: @escaping (Item) -> CGFloat?,
                @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.columnWidth = columnWidth
        self.spacing = spacing
        self.aspectRatio = aspectRatio
        self.content = content
    }

    public var body: some View {
        let count = UMUIMasonryLayout.columnCount(width: width, columnWidth: columnWidth, spacing: spacing)
        let actual = UMUIMasonryLayout.columnWidth(width: width, count: count, spacing: spacing)
        let ratios = items.map { aspectRatio($0) }
        let columns = UMUIMasonryLayout.columns(ratios: ratios, count: count, columnWidth: actual, spacing: spacing)

        HStack(alignment: .top, spacing: spacing) {
            ForEach(columns.indices, id: \.self) { column in
                LazyVStack(spacing: spacing) {
                    ForEach(columns[column], id: \.self) { index in
                        content(items[index])
                            .frame(width: actual, height: actual / UMUIMasonryLayout.clampedRatio(ratios[index]))
                    }
                }
                .frame(width: actual)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { width = $0 }
    }
}
