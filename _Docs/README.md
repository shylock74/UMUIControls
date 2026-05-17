# UMUIControls — API Documentation

`UMUIControls` is a premium, lightweight, self-contained SwiftUI control library specifically tailored for macOS 14+. It provides a comprehensive set of highly customizable, consistent, and accent-color-aware UI components designed for settings forms, inspector panels, and utility views.

This document serves as the complete, exhaustive, and synthetic API reference for all package controls.

---

## Table of Contents
1. [Core Features](#core-features)
2. [Component Index & Reference](#component-index--reference)
   - [UMUICapsuleButton](#1-umuicapsulebutton)
   - [UMUITextField](#2-umuitextfield)
   - [UMUIKnobControl](#3-umuiknobcontrol)
   - [UMUIColorPalettePicker](#4-umuicolorpalettepicker)
   - [UMUISlider](#5-umuislider-new)
   - [UMUIVerticalSlider](#6-umuiverticalslider-new)
   - [UMUISegmentedBar & UMUIMultiSegmentedBar](#7-umisegmentedbar--umuimultisegmentedbar-new)
   - [UMUINumberControl](#8-umuinumbercontrol)
   - [UMUIAngleControl](#9-umuianglecontrol)
   - [UMUIPositionGrid](#10-umuipositiongrid)
   - [UMUIRadioButton](#11-umuiradiobutton)
   - [UMUIMiniSwitch & UMUISmallSwitch](#12-umuiminiswitch--umuismallswitch)
   - [UMUISection](#13-umuisection)
   - [UMUITagBar](#14-umuitagbar)
   - [UMUITagEditor](#15-umuitageditor)
   - [UMUICheckerboard](#16-umuicheckerboard)
3. [Helper Extensions](#17-helper-extensions)
4. [Theming & Integration](#theming--integration)

---

## Core Features
- **macOS Oriented:** Designed strictly for macOS 14.0+ (`.macOS(.v14)`).
- **Accent-Color Aware:** Controls dynamically adapt to system or parent-level `.tint(_:)` / `.accentColor(_:)` styling without hardcoded values.
- **Dynamic Color Contrast:** High-contrast text color selector calculated via W3C relative luminance.
- **Zero Third-Party Dependencies:** 100% native SwiftUI and Swift Concurrency.

---

## Component Index & Reference

### 1. `UMUICapsuleButton`
A capsule-shaped button styled with responsive tactile micro-interactions and dynamic high-contrast text color detection.

#### Signatures & Initializers
```swift
// 1. Generic Content ViewBuilder
public init(
    style: UMUICapsuleButtonStyle = .gray,
    size: UMUICapsuleButtonSize = .normal,
    action: @escaping () -> Void,
    @ViewBuilder label: () -> Label
)

// 2. Convenience Text Title
public init(
    _ title: String,
    style: UMUICapsuleButtonStyle = .gray,
    size: UMUICapsuleButtonSize = .normal,
    action: @escaping () -> Void
) where Label == Text

// 3. Convenience Icon & Text
public init(
    _ title: String,
    systemImage: String,
    style: UMUICapsuleButtonStyle = .gray,
    size: UMUICapsuleButtonSize = .normal,
    action: @escaping () -> Void
) where Label == SwiftUI.Label<Text, Image>
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `style` | `UMUICapsuleButtonStyle` | `.gray` | The color theme: `.gray`, `.accent`, or `.custom(Color)`. |
| `size` | `UMUICapsuleButtonSize` | `.normal` | The sizing configuration: `.large`, `.normal`, or `.small`. |
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

#### Signature & Initializer
```swift
public init(
    label: String? = nil,
    placeholder: String = "",
    value: Binding<String>,
    size: UMUITextFieldSize = .normal,
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
| `size` | `UMUITextFieldSize` | `.normal` | Size configuration: `.normal` or `.small` (caption-sized). |
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
    size: CGFloat = 40,
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
| `size` | `CGFloat` | `40` | Outer diameter of the knob circle. |
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
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional leading label. |
| `selection` | `Binding<Color>` | *Required* | Bound selected Color. |
| `palette` | `[Color]` | `defaultPalette`| Preset swatches (HSL-harmonized list). |
| `labelWidth` | `CGFloat` | `80` | Horizontal space reserved for label. |

#### Thread Safety & Custom Colors
- **Thread Safety:** Integrates macOS native `NSColorSampler` for system color picking. The system callback executes on a background utility thread; the control explicitly dispatches back to `DispatchQueue.main` for binding writes to prevent background thread warnings.
- **Dynamic Swatch Addition:** If the eyedropper selects a custom color not in the `palette`, it generates a temporary selected "+ Custom" swatch in the flow list so the custom color is instantly visible and editable.

---

### 5. `UMUISlider` [NEW]
A custom premium horizontal slider matching Apple's macOS Control Center styling. Features a glassmorphic bar, dynamic accent fill, and a zoom thumb handle that displays only on interaction.

#### Signature & Initializer
```swift
public init(
    label: String? = nil,
    value: Binding<Double>,
    range: ClosedRange<Double> = 0...1,
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional leading label. |
| `value` | `Binding<Double>` | *Required* | Bound numeric value. |
| `range` | `ClosedRange<Double>`| `0...1` | Dynamic limits for the fader. |
| `labelWidth` | `CGFloat` | `80` | Horizontal space reserved for label. |

#### Micro-Interactions
- **Zero-Distance Click-to-Snap:** Clicking anywhere along the path immediately snaps the slider value to that horizontal coordinate.
- **Interactive Thumb Reveal:** The white circular grab thumb remains hidden inside the bar to avoid visual clutter and scales up to full size (`1.0`) only when the mouse hovers or drags.

---

### 6. `UMUIVerticalSlider` [NEW]
A high-fidelity vertical fader control with side tick-marks, a mixing desk horizontal pill fader knob, and coordinate reversing modes.

#### Signature & Initializer
```swift
public init(
    label: String? = nil,
    value: Binding<Double>,
    range: ClosedRange<Double> = 0...1,
    height: CGFloat = 120,
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
| `height` | `CGFloat` | `120` | Dynamic vertical height. |
| `inverted` | `Bool` | `false` | If true, max value is at the bottom (increases downward). |
| `labelWidth` | `CGFloat` | `80` | Label frame width. |

#### Graduation & Thumb Style
- **Graduation ticks:** Draws a structural ticks panel with precise step markers at `0%`, `25%`, `50%`, `75%`, and `100%`.
- **Fader Grip:** Emulates professional recording studio mixing faders using a wide rectangular grip handle featuring central horizontal guide lines.

---

### 7. `UMUISegmentedBar` & `UMUIMultiSegmentedBar` [NEW]
Visual segmented selection bars. Supports single-selection with a magnetic sliding pill backdrop, and multi-selection with individual glowing status slots.

#### Signatures
```swift
// 1. Single Selection
public init(
    label: String? = nil,
    options: [String],
    selection: Binding<String>,
    labelWidth: CGFloat = 80
)

// 2. Multi Selection
public init(
    label: String? = nil,
    options: [String],
    selection: Binding<Set<String>>,
    labelWidth: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String?` | `nil` | Optional leading label. |
| `options` | `[String]` | *Required* | Set of text string items. |
| `selection` | `Binding` | *Required* | Bound selection (a `String` or a `Set<String>`). |
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
| `labelWidth` | `CGFloat` | `50` | Horizontal space reserved for label. |
| `fieldWidth` | `CGFloat` | `60` | Horizontal space reserved for input. |

---

### 9. `UMUIAngleControl`
A rotary dial knob designed to edit angles visually.

#### Signature
```swift
public init(
    angle: Binding<Double>,
    size: CGFloat = 80
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `angle` | `Binding<Double>` | *Required* | Angle value in degrees, clamped between `-180` and `180`. |
| `size` | `CGFloat` | `80` | Knob diameter. |

#### Snapping Modifier
- Pressing `Command (⌘)` while rotating snaps the value to local `15°` increments.

---

### 10. `UMUIPositionGrid`
A 3×3 anchor selection panel mapping coordinates visually.

#### Signature
```swift
public init(
    selection: Binding<UMUIPosition>,
    action: (() -> Void)? = nil
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `selection` | `Binding<UMUIPosition>`| *Required* | Bound coordinate state. |
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
    action: @escaping () -> Void
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `selected` | `Bool` | *Required* | Filled/Selected visual state indicator. |
| `action` | `() -> Void` | *Required* | Click action. |

> [!IMPORTANT]
> **Memory Safety:** If the `action` closure captures reference types (like view controllers or view models), ensure you capture them weakly (e.g. `[weak self]`) to prevent strong reference cycles and memory leaks.

---

### 12. `UMUIMiniSwitch` & `UMUISmallSwitch`
Sized wrappers for standard SwiftUI toggle switches, optimized for dense sidebar layouts.

#### Signatures
```swift
public init(_ title: String, isOn: Binding<Bool>)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `String` | *Required* | Text tag adjacent to the toggle. |
| `isOn` | `Binding<Bool>`| *Required* | Target boolean state. |

---

### 13. `UMUISection`
A grouped container holding child components inside a consistent subtle border.

#### Signature
```swift
public init(
    _ title: String? = nil,
    @ViewBuilder content: () -> Content
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `String?` | `nil` | Optional header title rendered in small bold text. |
| `content` | `() -> Content` | *Required* | SwiftUI components grouped inside the card. |

---

### 14. `UMUITagBar`
A horizontal scrolling strip displaying selectable tags.

#### Signature
```swift
public init(
    tags: [String],
    selectedTags: Binding<Set<String>>
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `tags` | `[String]` | *Required* | Array of tags. |
| `selectedTags`| `Binding<Set<String>>`| *Required* | Currently active tags. Selection toggles membership. |

---

### 15. `UMUITagEditor`
An editable flow panel supporting addition, removal, and suggested popular tags.

#### Signature
```swift
public init(
    tags: Binding<[String]>,
    availableTags: [String] = []
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `tags` | `Binding<[String]>` | *Required* | Array of applied active tags. |
| `availableTags`| `[String]` | `[]` | Suggested popular tags in popover editor. |

---

### 16. `UMUICheckerboard`
A lightweight checkerboard pattern to overlay transparency in images or assets.

#### Signature
```swift
public init(
    squareSize: CGFloat = 20,
    color1: Color = .white,
    color2: Color = Color.gray.opacity(0.3)
)
```

#### Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `squareSize` | `CGFloat` | `20` | Size of checkerboard squares. |
| `color1` | `Color` | `.white` | Color of primary checker tiles. |
| `color2` | `Color` | `.gray.opacity(0.3)` | Color of secondary checker tiles. |

---

## 17. Helper Extensions

#### Text Elements
- **`UMUICaptionText`**: `Text` view formatted using `.caption` font.
- **`UMUICaptionGrayText`**: `Text` view formatted using `.caption` font and `.secondary` foreground color.

#### Color Utilities
- **`Color.darkGray`**: Custom hardcoded static dark gray `Color(white: 0.2)`.
- **`Color.contrastingTextColor(in: EnvironmentValues)`**: Computes relative luminance and resolves `.black` or `.white` dynamically depending on light/dark mode and surrounding values.

---

## Theming & Integration

The library relies entirely on system-aware styling rather than hardcoded themes. To globally override or configure the visual appearance of all components in your application, apply standard SwiftUI modifiers to the parent viewport:

```swift
ContentView()
    .tint(.purple)                 // Customizes accent colors
    .colorScheme(.dark)            // Forces dark mode adaptations
```
