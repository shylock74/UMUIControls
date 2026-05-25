# UMUIControls — API Documentation

`UMUIControls` is a premium, lightweight, self-contained SwiftUI control library specifically tailored for macOS. It provides a comprehensive set of highly customizable, consistent, and accent-color-aware UI components designed for settings forms, inspector panels, and utility views.

All controls support consistent sizing modes (`.normal` and `.small`), and **default to `.small`** to suit standard dense Mac preference pages and sidebars.

---

## Directory Structure

To maintain a clean modular architecture, components are structured into dedicated subfolders under `Sources/UMUIControls/Controls/`:
- **`UMTabBarUIView/`**: Tabs and horizontal navigation bar components.
- **`UMDisclosureGroup/`**: Flexible custom expandable disclosure cards and helpers.
- **`UMHSpacer/`**: Structured horizontal and vertical visual spacers.
- **`UMLeftObjectView/`**: Layout and text baseline positioning modifiers.
- Custom controls (e.g., `UMBoxView.swift`, `UMTappableSection.swift`, `UMCenter.swift`, `UMZInset.swift`) are organized as single, self-contained structural files.

---

## Table of Contents
1. [Core Features](#core-features)
2. [Component Index & Reference](#component-index--reference)
   - [UMUICapsuleButton](#1-umuicapsulebutton)
   - [UMUITextField](#2-umuitextfield)
   - [UMUIKnobControl](#3-umuiknobcontrol)
   - [UMUIColorPalettePicker](#4-umuicolorpalettepicker)
   - [UMUISlider](#5-umuislider)
   - [UMUIVerticalSlider](#6-umuiverticalslider)
   - [UMUISegmentedBar & UMUIMultiSegmentedBar](#7-umuisegmentedbar--umuimultisegmentedbar)
   - [UMUINumberControl](#8-umuinumbercontrol)
   - [UMUIAngleControl](#9-umuianglecontrol)
   - [UMUIPositionGrid](#10-umuipositiongrid)
   - [UMUIRadioButton](#11-umuiradiobutton)
   - [UMUIMiniSwitch & UMUISmallSwitch](#12-umuiminiswitch--umuismallswitch)
   - [UMUISection](#13-umuisection)
   - [UMUITagBar](#14-umuitagbar)
   - [UMUITagEditor](#15-umuitageditor)
   - [UMUICheckerboard](#16-umuicheckerboard)
   - [UMTabBarUIView & UMTabBarButton](#17-umtabbaruiview--umtabbarbutton)
   - [UMDisclosureGroup & Variants](#18-umdisclosuregroup--variants)
   - [UMTappableSection](#19-umtappablesection)
   - [UMBoxView](#20-umboxview)
   - [UMHSpacer & UMVSpacer](#21-umhspacer--umvspacer)
   - [UMCenter](#22-umcenter)
   - [UMLeftObjectView & Alignment Modifiers](#23-umleftobjectview--alignment-modifiers)
   - [UMZInset](#24-umzinset)
3. [Helper Extensions](#25-helper-extensions)
4. [Theming & Integration](#theming--integration)

---

## Core Features
- **macOS Oriented:** Designed strictly for macOS 11.0+ (`.macOS(.v11)`).
- **Accent-Color Aware:** Controls dynamically adapt to system or parent-level `.tint(_:)` / `.accentColor(_:)` styling without hardcoded values.
- **Dynamic Color Contrast:** High-contrast text color selector calculated via W3C relative luminance.
- **Unified Sizing Sweep:** All controls support `.normal` and `.small` sizing modes, defaulting to `.small` for premium visual density.
- **Zero Third-Party Dependencies:** 100% native SwiftUI.

---

## Component Index & Reference

### 1. `UMUICapsuleButton`
A capsule-shaped button styled with responsive tactile micro-interactions and dynamic high-contrast text color detection.

#### Signatures & Initializers
```swift
// 1. Generic Content ViewBuilder
public init(
    style: UMUICapsuleButtonStyle = .gray,
    size: UMUICapsuleButtonSize = .small,
    action: @escaping () -> Void,
    @ViewBuilder label: () -> Label
)

// 2. Convenience Text Title
public init(
    _ title: String,
    style: UMUICapsuleButtonStyle = .gray,
    size: UMUICapsuleButtonSize = .small,
    action: @escaping () -> Void
) where Label == Text

// 3. Convenience Icon & Text
public init(
    _ title: String,
    systemImage: String,
    style: UMUICapsuleButtonStyle = .gray,
    size: UMUICapsuleButtonSize = .small,
    action: @escaping () -> Void
) where Label == SwiftUI.Label<Text, Image>
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `style` | `UMUICapsuleButtonStyle` | `.gray` | The color theme: `.gray`, `.accent`, or `.custom(Color)`. |
| `size` | `UMUICapsuleButtonSize` | `.small` | The sizing configuration: `.large`, `.normal`, or `.small`. |
| `action` | `() -> Void` | *Required* | Closure invoked when the button is clicked. |
| `label` | `View` | *Required* | SwiftUI content layout wrapped inside the capsule. |

> [!IMPORTANT]
> **Memory Safety:** If the `action` closure captures reference types (like view controllers or view models), ensure you capture them weakly (e.g. `[weak self]`) to prevent strong reference cycles and memory leaks.

#### Color & Sizing Enums
```swift
public enum UMUICapsuleButtonStyle: Sendable, Equatable {
    case gray                // Gray bg; black/white text depending on contrast
    case accent              // System accent bg; black/white text depending on contrast
    case custom(Color)       // Custom color bg; black/white text calculated dynamically
}

public enum UMUICapsuleButtonSize: Sendable, Equatable {
    case large               // .title font, 24px horizontal / 12px vertical padding
    case normal              // .body font, 16px horizontal / 8px vertical padding
    case small               // .caption font, 12px horizontal / 6px vertical padding
}
```

#### Interactive Behavior
- **Hover:** Scales to `1.02`, brightens by `+0.04`, and adds a soft shadow.
- **Press:** Compresses to `0.96` and dims by `-0.08` for mechanical feedback.

---

### 2. `UMUITextField`
A text entry control featuring an optional leading label, custom rounded-rect styling with focus ring glow, secure entry support, and a non-blocking 0.3s background-threaded debounced binding. 

*Fully backward-compatible with macOS 11 (uses legacy bindings when `@FocusState` is unavailable).*

#### Signature & Initializer
```swift
public init(
    label: String? = nil,
    placeholder: String = "",
    value: Binding<String>,
    size: UMUITextFieldSize = .small,
    isSecure: Bool = false,
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional label displayed horizontally on the left of the input. |
| `placeholder` | `String` | `""` | Helper placeholder string. |
| `value` | `Binding<String>` | *Required* | Parent binding updated via debounce/commit. |
| `size` | `UMUITextFieldSize` | `.small` | Size configuration: `.normal` or `.small` (caption-sized). |
| `isSecure` | `Bool` | `false` | Enables password hide/reveal mode (bullets vs characters). |
| `labelWidth` | `CGFloat` | `80` | Horizontal width allocated for the leading label. |

#### Timing & Focus Logic
- **0.3s Debounce:** Local keystrokes update local state instantly for latency-free typing. Synchronization to `value` is debounced by `300ms` completely in a background queue (`DispatchQueue.global(qos: .userInteractive)`), leaving the MainActor entirely unencumbered.
- **Instant Sync:** Synchronizes immediately (bypassing debounce) on **Enter/Return**, **blur (losing focus)**, or **disappear (`onDisappear`)**.
- **Eye Toggle:** Retains keyboard focus on the field programmatically so typing is never interrupted when toggling password visibility.

---

### 3. `UMUIKnobControl`
A professional-grade visual rotary dial knob optimized for creative, parameter-dense inspectors (like audio volume/panning VST layouts).

#### Signature & Initializer
```swift
public init(
    label: String? = nil,
    value: Binding<Double>,
    range: ClosedRange<Double> = 0...1,
    defaultValue: Double? = nil,
    size: UMUIKnobControlSize = .small,
    customDiameter: CGFloat? = nil,
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional leading label text. |
| `value` | `Binding<Double>` | *Required* | Bound double value adjusted by the knob. |
| `range` | `ClosedRange<Double>`| `0...1` | Active clamped bounds for values. |
| `defaultValue`| `Double?` | `nil` | Optional default value reset on double-click. |
| `size` | `UMUIKnobControlSize` | `.small` | Sizing configuration: `.normal` (40pt diameter) or `.small` (26pt diameter). |
| `customDiameter`| `CGFloat?` | `nil` | Optional custom diameter override in points. |
| `labelWidth` | `CGFloat` | `80` | Horizontal width reserved for label. |

#### Premium Features
- **Vertical Drag Gestures:** Dragging vertically up increases value, dragging down decreases it. Bypasses standard circular tracking to guarantee industry-grade control precision.
- **Double-Click Reset:** Double-clicking the knob triggers a quick spring transition back to its `defaultValue`.
- **Value Tooltip:** Hovering or dragging triggers a dynamic tooltip popup centered over the dial, revealing the decimal value in real-time.

---

### 4. `UMUIColorPalettePicker`
A compact color selection strip combining preconfigured swatches with a system-wide magnifying glass eyedropper tool.

#### Signature & Initializer
```swift
public init(
    label: String? = nil,
    selection: Binding<Color>,
    palette: [Color] = defaultPalette,
    size: UMUIColorPalettePickerSize = .small,
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional leading label. |
| `selection` | `Binding<Color>` | *Required* | Bound selected Color. |
| `palette` | `[Color]` | `defaultPalette`| Preset swatches (HSL-harmonized list). |
| `size` | `UMUIColorPalettePickerSize`| `.small` | Sizing configuration: `.normal` or `.small`. |
| `labelWidth` | `CGFloat` | `80` | Horizontal space reserved for label. |

#### Thread Safety & Custom Colors
- **Thread Safety:** Integrates macOS native `NSColorSampler` for system color picking. The system callback executes on a background thread; the control explicitly dispatches back to `DispatchQueue.main` for binding writes to prevent background thread warnings.
- **Dynamic Swatch Addition:** If the eyedropper selects a custom color not in the `palette`, it generates a temporary selected "+ Custom" swatch in the flow list so the custom color is instantly visible and editable.

---

### 5. `UMUISlider`
A custom premium horizontal slider matching Apple's macOS Control Center styling. Features a glassmorphic bar, dynamic accent fill, and a zoom thumb handle that displays only on interaction.

#### Signature & Initializer
```swift
public init(
    label: String? = nil,
    value: Binding<Double>,
    range: ClosedRange<Double> = 0...1,
    size: UMUISliderSize = .small,
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional leading label. |
| `value` | `Binding<Double>` | *Required* | Bound numeric value. |
| `range` | `ClosedRange<Double>`| `0...1` | Dynamic limits for the fader. |
| `size` | `UMUISliderSize` | `.small` | Sizing configuration: `.normal` (12pt track, 16pt thumb) or `.small` (8pt track, 12pt thumb). |
| `labelWidth` | `CGFloat` | `80` | Horizontal space reserved for label. |

#### Micro-Interactions
- **Zero-Distance Click-to-Snap:** Clicking anywhere along the path immediately snaps the slider value to that horizontal coordinate.
- **Interactive Thumb Reveal:** The white circular grab thumb remains hidden inside the bar to avoid visual clutter and scales up to full size (`1.0`) only when the mouse hovers or drags.

---

### 6. `UMUIVerticalSlider`
A high-fidelity vertical fader control with side tick-marks, a mixing desk horizontal pill fader knob, and coordinate reversing modes.

#### Signature & Initializer
```swift
public init(
    label: String? = nil,
    value: Binding<Double>,
    range: ClosedRange<Double> = 0...1,
    height: CGFloat? = nil,
    size: UMUIVerticalSliderSize = .small,
    inverted: Bool = false,
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional leading label text. |
| `value` | `Binding<Double>` | *Required* | Bound double value. |
| `range` | `ClosedRange<Double>`| `0...1` | Clamped range bounds. |
| `height` | `CGFloat?` | `nil` | Dynamic vertical height. Defaults to 150px in `.normal` and 110px in `.small`. |
| `size` | `UMUIVerticalSliderSize`| `.small` | Sizing configuration: `.normal` or `.small`. |
| `inverted` | `Bool` | `false` | If true, max value is at the bottom (increases downward). |
| `labelWidth` | `CGFloat` | `80` | Label frame width. |

#### Graduation & Thumb Style
- **Graduation Ticks:** Draws a structural ticks panel with precise step markers at `0%`, `25%`, `50%`, `75%`, and `100%`.
- **Fader Grip:** Emulates professional recording studio mixing faders using a wide rectangular grip handle featuring central horizontal guide lines.

---

### 7. `UMUISegmentedBar` & `UMUIMultiSegmentedBar`
Visual segmented selection bars. Supports single-selection with a magnetic sliding pill backdrop, and multi-selection with individual glowing status slots.

#### Signatures
```swift
// 1. Single Selection
public init(
    label: String? = nil,
    options: [String],
    selection: Binding<String>,
    size: UMUISegmentedBarSize = .small,
    labelWidth: CGFloat = 80
)

// 2. Multi Selection
public init(
    label: String? = nil,
    options: [String],
    selection: Binding<Set<String>>,
    size: UMUISegmentedBarSize = .small,
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional leading label. |
| `options` | `[String]` | *Required* | Set of text string items. |
| `selection` | `Binding` | *Required* | Bound selection (a `String` or a `Set<String>`). |
| `size` | `UMUISegmentedBarSize`| `.small` | Sizing configuration: `.normal` or `.small`. |
| `labelWidth` | `CGFloat` | `80` | Horizontal width reserved for label. |

#### Gliding Mechanisms
- **Gliding Pill (Single-Selection):** Employs SwiftUI's `@Namespace` and hardware-accelerated `matchedGeometryEffect` to perform buttery-smooth gliding animations from one segment to the next.
- **Individual Glow (Multi-Selection):** Toggles individual options instantly, and active items glow in the accent color, matching the look of side-panel state toggles.

---

### 8. `UMUINumberControl`
A compact horizontal slider/field combo for fine-tuning double values.

#### Signature
```swift
public init(
    title: String,
    value: Binding<Double>,
    range: ClosedRange<Double>,
    isPercentage: Bool = false,
    unit: String? = nil,
    decimals: Int = 0,
    size: UMUINumberControlSize = .small,
    labelWidth: CGFloat = 50,
    fieldWidth: CGFloat = 60
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `String` | *Required* | Leading label. |
| `value` | `Binding<Double>` | *Required* | Numeric binding value. |
| `range` | `ClosedRange<Double>`| *Required* | Clamped bounds for slider. |
| `isPercentage`| `Bool` | `false` | If true, multiplies display value by 100 and sets unit to `%`. |
| `unit` | `String?` | `nil` | Appended text unit (e.g. "px", "s"). |
| `decimals` | `Int` | `0` | Fraction precision of text box. |
| `size` | `UMUINumberControlSize`| `.small` | Sizing configuration: `.normal` or `.small`. |
| `labelWidth` | `CGFloat` | `50` | Horizontal space reserved for label. |
| `fieldWidth` | `CGFloat` | `60` | Horizontal space reserved for input. |

---

### 9. `UMUIAngleControl`
A rotary dial knob designed to edit angles visually.

#### Signature
```swift
public init(
    angle: Binding<Double>,
    size: UMUIAngleControlSize = .small,
    customDiameter: CGFloat? = nil
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `angle` | `Binding<Double>` | *Required* | Angle value in degrees, clamped between `-180` and `180`. |
| `size` | `UMUIAngleControlSize` | `.small` | Sizing configuration: `.normal` (80pt diameter) or `.small` (50pt diameter). |
| `customDiameter`| `CGFloat?` | `nil` | Optional custom diameter override in points. |

#### Snapping Modifier
- Pressing `Command (⌘)` while rotating snaps the value to local `15°` increments.

---

### 10. `UMUIPositionGrid`
A 3×3 anchor selection panel mapping coordinates visually.

#### Signature
```swift
public init(
    selection: Binding<UMUIPosition>,
    size: UMUIPositionGridSize = .small,
    action: (() -> Void)? = nil
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `selection` | `Binding<UMUIPosition>`| *Required* | Bound coordinate state. |
| `size` | `UMUIPositionGridSize` | `.small` | Sizing configuration: `.normal` (26pt buttons) or `.small` (20pt buttons). |
| `action` | `(() -> Void)?` | `nil` | Callback executed after selected coordinate changes. |

> [!IMPORTANT]
> **Memory Safety:** If the `action` closure captures reference types (like view controllers or view models), ensure you capture them weakly (e.g. `[weak self]`) to prevent strong reference cycles and memory leaks.

#### UMUIPosition Enum Cases
`topLeft`, `top`, `topRight`, `left`, `center`, `right`, `bottomLeft`, `bottom`, `bottomRight`.

---

### 11. `UMUIRadioButton`
A minimalist circular radio button using SF Symbols.

#### Signature
```swift
public init(
    selected: Bool,
    size: UMUIRadioButtonSize = .small,
    action: @escaping () -> Void
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `selected` | `Bool` | *Required* | Filled/Selected visual state indicator. |
| `size` | `UMUIRadioButtonSize`| `.small` | Sizing configuration: `.normal` (body font size) or `.small` (caption font size). |
| `action` | `() -> Void` | *Required* | Click action. |

> [!IMPORTANT]
> **Memory Safety:** If the `action` closure captures reference types (like view controllers or view models), ensure you capture them weakly (e.g. `[weak self]`) to prevent strong reference cycles and memory leaks.

---

### 12. `UMUIMiniSwitch` & `UMUISmallSwitch`
Sized wrappers for standard SwiftUI toggle switches, optimized for dense sidebar layouts.

#### Signatures
```swift
// UMUIMiniSwitch (extremely compact layout)
public init(
    _ title: String, 
    isOn: Binding<Bool>, 
    size: UMUISwitchSize = .small
)

// UMUISmallSwitch (standard sidebar layout)
public init(
    _ title: String, 
    isOn: Binding<Bool>, 
    size: UMUISwitchSize = .small
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `String` | *Required* | Text tag adjacent to the toggle. |
| `isOn` | `Binding<Bool>`| *Required* | Target boolean state. |
| `size` | `UMUISwitchSize` | `.small` | Sizing configuration: `.normal` or `.small`. |

---

### 13. `UMUISection`
A grouped container holding child components inside a consistent subtle border.

#### Signature
```swift
public init(
    _ title: String? = nil,
    size: UMUISectionSize = .small,
    @ViewBuilder content: () -> Content
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `String?` | `nil` | Optional header title rendered in small bold text. |
| `size` | `UMUISectionSize` | `.small` | Sizing configuration: `.normal` or `.small`. |
| `content` | `() -> Content` | *Required* | SwiftUI components grouped inside the card. |

---

### 14. `UMUITagBar`
A horizontal scrolling strip displaying selectable tags.

#### Signature
```swift
public init(
    tags: [String],
    selectedTags: Binding<Set<String>>,
    size: UMUITagBarSize = .small
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `tags` | `[String]` | *Required* | Array of tags. |
| `selectedTags`| `Binding<Set<String>>`| *Required* | Currently active tags. Selection toggles membership. |
| `size` | `UMUITagBarSize` | `.small` | Sizing configuration: `.normal` or `.small`. |

---

### 15. `UMUITagEditor`
An editable flow panel supporting addition, removal, and suggested popular tags.

#### Signature
```swift
public init(
    tags: Binding<[String]>,
    availableTags: [String] = [],
    size: UMUITagEditorSize = .small
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `tags` | `Binding<[String]>` | *Required* | Array of applied active tags. |
| `availableTags`| `[String]` | `[]` | Suggested popular tags in popover editor. |
| `size` | `UMUITagEditorSize`| `.small` | Sizing configuration: `.normal` or `.small`. |

---

### 16. `UMUICheckerboard`
A lightweight, high-performance checkerboard pattern to overlay transparency in images or assets.

#### Signature
```swift
public init(
    size: UMUICheckerboardSize = .small,
    squareSize: CGFloat? = nil,
    color1: Color = .white,
    color2: Color = Color.gray.opacity(0.3)
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `size` | `UMUICheckerboardSize`| `.small` | Sizing configuration: `.normal` or `.small`. |
| `squareSize` | `CGFloat?` | `nil` | Optional custom square size override (overrides sizing mode). |
| `color1` | `Color` | `.white` | Color of primary checker tiles. |
| `color2` | `Color` | `.gray.opacity(0.3)` | Color of secondary checker tiles. |

---

### 17. `UMTabBarUIView` & `UMTabBarButton`
A segmented horizontal tab bar controller with responsive bounding background highlights and custom rounded corner layouts.

#### Initializer
```swift
public init(
    labelAndIds: [LabelAndId],
    selectedId: Binding<String>,
    selectedColor: Color = .mildDarkGray
)
```

#### `LabelAndId` Structure
```swift
public struct LabelAndId: Identifiable, Equatable {
    public var id: String
    public var label: String
    public var icon: String?
}
```

---

### 18. `UMDisclosureGroup` & Variants
A rich set of expandable disclosure card containers styled with clean bounding containers. Available in five configurations:
- **`UMDisclosureGroup`**: Standard expandable toggle group card.
- **`UMExpansionDisclosureGroup`**: An interactive text field header with expandable content.
- **`UMSwitchExpansionDisclosureGroup`**: Expandable layout tied directly to a compact switch control.
- **`UMExpansionDisclosureSGroup`**: Expandable card with minimal visual noise.
- **`UMGeneralDisclosureGroup`**: Expandable group using a fully customized header ViewBuilder.

**Usage Example:**
```swift
@State private var isExpanded = false
UMDisclosureGroup("Advanced Tuning", expanded: $isExpanded) {
    Text("Configure fine variables here...")
}
```

---

### 19. `UMTappableSection`
A beautiful expandable card section container that expands/collapses when tapping anywhere on the title segment. Leverages `UMUISection` under the hood.

#### Signature
```swift
public init(
    _ title: String,
    open: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
)
```

---

### 20. `UMBoxView`
A visual decorative layout grouping container drawing a continuous rounded stroke border and dynamic background overlay.

#### Signature
```swift
public init(
    cornerRadius: CGFloat = 10,
    borderWidth: CGFloat = 2,
    backColor: Color? = nil,
    foreColor: Color
)
```

---

### 21. `UMHSpacer` & `UMVSpacer`
Clean, native horizontal and vertical spacing layout boxes drawing empty spacing areas.
- **`UMHSpacer(20)`**: Adds a horizontal transparent gap.
- **`UMVSpacer(10)`**: Adds a vertical transparent gap.

---

### 22. `UMCenter`
A layout ViewModifier utility that centers any target view horizontally, vertically, or in both directions.

#### Extension Method
`someView.umCenter(_ direction: UMCenter.Direction)`

---

### 23. `UMLeftObjectView` & Alignment Modifiers
A rich collection of layout positioning ViewModifiers that position elements within dynamic frames:
- **`.leftObject(width: CGFloat?)`**: Left-aligns a view (optionally restricting its width).
- **`.umCentered()`**: Centers a view horizontally.
- **`.umZCentered()`**: Centers a view vertically.

---

### 24. `UMZInset`
A bounding layout modifier that positions inner content toward a specific corner or edge inside structural grid blocks.

#### Extension Method
`someView.umZInset(_ corner: UMZInset.Corner)`

---

## 25. Helper Extensions

#### Text Elements
- **`UMUICaptionText`**: `Text` view formatted using `.caption` font.
- **`UMUICaptionGrayText`**: `Text` view formatted using `.caption` font and `.secondary` foreground color.
- **`CaptionText`**: A backward-compatible typealias pointing to `UMUICaptionGrayText`.

#### Color Utilities
- **`Color.darkGray`**: Custom hardcoded static dark gray `Color(white: 0.2)`.
- **`Color.mildDarkGray`**: Custom mild dark gray color `Color(white: 0.3)`.
- **`Color.boxGray`**: Custom dark gray background `Color(white: 0.15)` for cards.
- **`Color.contrastingTextColor(in: EnvironmentValues)`**: Computes relative luminance and resolves `.black` or `.white` dynamically depending on light/dark mode and surrounding values.

---

## Theming & Integration

The library relies entirely on system-aware styling rather than hardcoded themes. To globally override or configure the visual appearance of all components in your application, apply standard SwiftUI modifiers to the parent viewport:

```swift
ContentView()
    .tint(.purple)                 // Customizes accent colors
    .colorScheme(.dark)            // Forces dark mode adaptations
```
