import Testing
import CoreGraphics
@testable import UMUIControls

@Suite struct UMUIMasonryLayoutTests {
    @Test func eachItemGoesIntoTheShortestColumn() {
        // Tall (ratio 0.5) first, then three wide ones: the wide ones stack in the other column.
        let columns = UMUIMasonryLayout.columns(ratios: [0.5, 2, 2, 2], count: 2, columnWidth: 100, spacing: 0)
        #expect(columns == [[0], [1, 2, 3]])
    }

    @Test func aTieGoesToTheLeftmostColumn() {
        let columns = UMUIMasonryLayout.columns(ratios: [1, 1, 1, 1, 1], count: 3, columnWidth: 100, spacing: 8)
        #expect(columns == [[0, 3], [1, 4], [2]])
    }

    @Test func oneColumnKeepsTheOrder() {
        #expect(UMUIMasonryLayout.columns(ratios: [1, 2, 0.5], count: 1, columnWidth: 100, spacing: 8) == [[0, 1, 2]])
        #expect(UMUIMasonryLayout.columns(ratios: [1, 2, 0.5], count: 0, columnWidth: 100, spacing: 8) == [[0, 1, 2]])
    }

    @Test func noItemsGiveEmptyColumns() {
        #expect(UMUIMasonryLayout.columns(ratios: [], count: 3, columnWidth: 100, spacing: 8) == [[], [], []])
    }

    @Test func ratiosAreClampedAndUnknownOnesAreSquare() {
        #expect(UMUIMasonryLayout.clampedRatio(nil) == 1)
        #expect(UMUIMasonryLayout.clampedRatio(0) == 1)
        #expect(UMUIMasonryLayout.clampedRatio(.nan) == 1)
        #expect(UMUIMasonryLayout.clampedRatio(10) == 2.5)
        #expect(UMUIMasonryLayout.clampedRatio(0.1) == 0.4)
        #expect(UMUIMasonryLayout.clampedRatio(1.5) == 1.5)
    }

    @Test func columnCountFollowsTheWidth() {
        #expect(UMUIMasonryLayout.columnCount(width: 0, columnWidth: 200, spacing: 8) == 1)
        #expect(UMUIMasonryLayout.columnCount(width: 199, columnWidth: 200, spacing: 8) == 1)
        #expect(UMUIMasonryLayout.columnCount(width: 408, columnWidth: 200, spacing: 8) == 2)
        #expect(UMUIMasonryLayout.columnCount(width: 407, columnWidth: 200, spacing: 8) == 1)
        #expect(UMUIMasonryLayout.columnCount(width: 1000, columnWidth: 200, spacing: 8) == 4)
    }

    @Test func columnsFillTheWidth() {
        let w = UMUIMasonryLayout.columnWidth(width: 1000, count: 4, spacing: 8)
        #expect(abs(w * 4 + 8 * 3 - 1000) < 0.001)
    }
}
