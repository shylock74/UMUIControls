# UMUIControls

`UMUIControls` is a comprehensive, self-contained SwiftUI control library tailored for macOS applications. It provides a set of highly customizable, consistent, and accent-color-aware UI components, originally extracted from production applications to establish a unified design language.

## Features

- **macOS Native:** Designed specifically for macOS 14+ (`.macOS(.v14)`).
- **Accent Color Aware:** All interactive controls automatically respect the app's `Color.accentColor` out of the box, ensuring perfect thematic consistency without hardcoding colors.
- **Zero External Dependencies:** The package is entirely self-contained and does not rely on any third-party frameworks.
- **Swift 6 Ready:** Fully compatible with Swift 5 and Swift 6 language modes.

---

## Installation

You can add `UMUIControls` to your Xcode project as a Local Package:
1. In Xcode, go to **File > Add Package Dependencies...**
2. Click **Add Local...** at the bottom left.
3. Select the `UMUIControls` folder.
4. Add the `UMUIControls` library to your app target.

---

## Components Documentation

### 1. `UMUINumberControl`
A highly compact horizontal control that combines a label, a slider, a text field, and an optional unit indicator. It supports raw values, percentage display modes, and custom decimal precision.

**Usage Examples:**

```swift
@State private var opacity: Double = 0.5
@State private var rotation: Double = 45.0
@State private var blurRadius: Double = 10.0

// 1. Percentage Mode (multiplies value by 100 for display, appends "%")
UMUINumberControl(
    title: "Opacity",
    value: $opacity,
    range: 0...1,
    isPercentage: true
)

// 2. Standard Mode with explicit Unit and no decimals
UMUINumberControl(
    title: "Rotation",
    value: $rotation,
    range: -180...180,
    unit: "°",
    decimals: 0
)

// 3. Custom widths and decimal precision
UMUINumberControl(
    title: "Blur",
    value: $blurRadius,
    range: 0...100,
    unit: "px",
    decimals: 1,
    labelWidth: 60,
    fieldWidth: 70
)
```

**Parameters:**
- `title: String` - The leading label text.
- `value: Binding<Double>` - The underlying numeric value.
- `range: ClosedRange<Double>` - The valid range for the slider.
- `isPercentage: Bool` - If `true`, the displayed value is `value * 100` and the default unit is `%`.
- `unit: String?` - An optional string appended after the text field (e.g., "px", "s").
- `decimals: Int` - Decimal precision for the text field (default: `0`).
- `labelWidth: CGFloat` - Width of the leading label area (default: `50`).
- `fieldWidth: CGFloat` - Width of the text field (default: `60`).

---

### 2. `UMUIAngleControl`
A circular dial control for visually editing an angle value. It features a draggable indicator knob and visual tick marks.

**Key Feature:** Holding the `Command (⌘)` key while dragging enables automatic snapping to 15° intervals.

**Usage Example:**

```swift
@State private var angle: Double = 0.0

UMUIAngleControl(angle: $angle, size: 80)
```

**Parameters:**
- `angle: Binding<Double>` - The angle in degrees (bound between `-180` and `180`).
- `size: CGFloat` - The diameter of the dial (default: `80`).

---

### 3. `UMUIPositionGrid`
A 3×3 grid of buttons representing physical anchor points (e.g., Top Left, Center, Bottom Right). Selecting a button highlights it with the app's accent color.

**Usage Example:**

```swift
@State private var anchor: UMUIPosition = .center

UMUIPositionGrid(selection: $anchor) {
    print("Anchor changed to \(anchor.rawValue)")
}
```

**Parameters:**
- `selection: Binding<UMUIPosition>` - The currently selected position. Uses the `UMUIPosition` enum.
- `action: (() -> Void)?` - An optional closure executed immediately after a new position is selected.

**`UMUIPosition` Enum Cases:**
`.topLeft`, `.top`, `.topRight`, `.left`, `.center`, `.right`, `.bottomLeft`, `.bottom`, `.bottomRight`.

---

### 4. `UMUIRadioButton`
A minimalist radio button implementation using SF Symbols. 

**Usage Example:**

```swift
@State private var selectedOption: Int = 1

HStack {
    UMUIRadioButton(selected: selectedOption == 1) { selectedOption = 1 }
    Text("Option 1")
    
    UMUIRadioButton(selected: selectedOption == 2) { selectedOption = 2 }
    Text("Option 2")
}
```

**Parameters:**
- `selected: Bool` - Whether the radio button is in the filled state.
- `action: () -> Void` - The closure to execute when tapped.

---

### 5. `UMUIMiniSwitch` & `UMUISmallSwitch`
Standard SwiftUI `Toggle` views pre-configured with specific control sizes and caption fonts to guarantee compact, consistent layouts in dense inspector panels.

**Usage Example:**

```swift
@State private var isEnabled: Bool = false

// Ultra-compact (.mini)
UMUIMiniSwitch("Enable Feature", isOn: $isEnabled)

// Slightly larger (.small)
UMUISmallSwitch("Advanced Mode", isOn: $isEnabled)
```

**Parameters:**
- `title: String` - The label of the switch.
- `isOn: Binding<Bool>` - Binding to the boolean state.

---

### 6. `UMUISection`
A container view that groups related controls together. It provides consistent internal padding, a subtle rounded border, and an optional title.

**Usage Example:**

```swift
// Section with a title header
UMUISection("Appearance") {
    UMUINumberControl(title: "Opacity", value: $opacity, range: 0...1)
    UMUIMiniSwitch("Hidden", isOn: $isHidden)
}

// Section without a title
UMUISection {
    Text("Miscellaneous Controls")
}
```

**Parameters:**
- `title: String?` - The optional title string displayed in bold at the top of the section.
- `content: () -> Content` - A `@ViewBuilder` closure containing the controls.

---

### 7. `UMUITagBar`
A horizontal scrolling bar of selectable tag chips. Excellent for filtering or multiselection.

**Usage Example:**

```swift
let allCategories = ["Design", "Development", "Marketing"]
@State private var activeCategories: Set<String> = []

UMUITagBar(tags: allCategories, selectedTags: $activeCategories)
```

**Parameters:**
- `tags: [String]` - The complete array of tags to display.
- `selectedTags: Binding<Set<String>>` - A binding to the set of currently active tags. Tapping a tag toggles its presence in this set.

---

### 8. `UMUITagEditor`
An inline editor for adding and removing tags from an array. It displays existing tags as chips with "Remove" buttons, and includes a popover menu to add new tags from a suggested list or type custom ones.

**Usage Example:**

```swift
@State private var documentTags: [String] = ["Urgent"]
let suggestedTags = ["Urgent", "Review", "Approved", "Draft"]

UMUITagEditor(tags: $documentTags, availableTags: suggestedTags)
```

**Parameters:**
- `tags: Binding<[String]>` - Binding to the array of applied tags.
- `availableTags: [String]` - Array of suggested tags to display in the "Popular Tags" popover. (Default: `[]`).

---

### 9. `UMUICheckerboard`
A lightweight, Canvas-based checkerboard pattern view. Usually placed behind images or colors to clearly indicate transparency (alpha channels).

**Usage Example:**

```swift
ZStack {
    UMUICheckerboard(squareSize: 15)
    
    Image("transparent_logo")
        .resizable()
        .scaledToFit()
}
.frame(width: 200, height: 200)
```

**Parameters:**
- `squareSize: CGFloat` - The size of each checkerboard square. (Default: `20`).
- `color1: Color` - Primary color. (Default: `.white`).
- `color2: Color` - Secondary color. (Default: `.gray.opacity(0.3)`).

---

### 10. Helpers

`UMUIControls` includes a few helper views and extensions to speed up UI development:

#### Text Helpers
- `UMUICaptionText("Text")` - Renders text using the `.caption` font.
- `UMUICaptionGrayText("Text")` - Renders text using the `.caption` font and `.secondary` foreground style.

#### Color Extensions
- `Color.darkGray` - A standardized dark gray color (`Color(white: 0.2)`).

---

## Theming and Colors
This package does **not** rely on hardcoded colors like `.blue`. Instead, it extensively uses `.accentColor` and `.primary` / `.secondary` semantic colors. 

To change the theme of these controls across your app, simply change your app's Global Accent Color in the Asset Catalog, or apply the `.tint(_:)` / `.accentColor(_:)` modifier to a parent view:

```swift
VStack {
    UMUINumberControl(...)
    UMUIAngleControl(...)
}
.tint(.purple) // All UMUIControls inside will use purple
```

## License
Created by Ulti Media.
