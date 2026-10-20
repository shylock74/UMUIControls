import Testing
@testable import UMUIControls

@Suite struct UMUIResizableDividerTests {
    @Test func trailingPaneShrinksWhenDraggedTowardsIt() {
        // Pane on the right/bottom: dragging right/down makes it smaller.
        #expect(UMUIResizableDivider.resized(from: 300, translation: 40, edge: .trailing, range: 100...500) == 260)
        #expect(UMUIResizableDivider.resized(from: 300, translation: -40, edge: .trailing, range: 100...500) == 340)
    }

    @Test func leadingPaneGrowsWhenDraggedAway() {
        #expect(UMUIResizableDivider.resized(from: 300, translation: 40, edge: .leading, range: 100...500) == 340)
    }

    @Test func sizeIsClampedToTheRange() {
        #expect(UMUIResizableDivider.resized(from: 300, translation: -900, edge: .trailing, range: 100...500) == 500)
        #expect(UMUIResizableDivider.resized(from: 300, translation: 900, edge: .trailing, range: 100...500) == 100)
    }
}
