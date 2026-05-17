# UMUIControls — API Documentation

`UMUIControls` is a premium, lightweight, self-contained SwiftUI control library specifically tailored for macOS 14+. It provides a comprehensive set of highly customizable, consistent, and accent-color-aware UI components designed for settings forms, inspector panels, and utility views.

This document serves as the complete, exhaustive, and synthetic API reference for all package controls.

---

## Table of Contents
1. [Core Features](#core-features)
2. [Component Index & Reference](#component-index--reference)
   - [UMUICapsuleButton](#1-umuicapsulebutton-new)
   - [UMUITextField](#2-umuitextfield-new)
   - [UMUINumberControl](#3-umuinumbercontrol)
   - [UMUIAngleControl](#4-umuianglecontrol)
   - [UMUIPositionGrid](#5-umuipositiongrid)
   - [UMUIRadioButton](#6-umuiradiobutton)
   - [UMUIMiniSwitch & UMUISmallSwitch](#7-umuiminiswitch--umuismallswitch)
   - [UMUISection](#8-umuisection)
   - [UMUITagBar](#9-umuitagbar)
   - [UMUITagEditor](#10-umuitageditor)
   - [UMUICheckerboard](#11-umuicheckerboard)
3. [Helper Extensions](#12-helper-extensions)
4. [Theming & Integration](#theming--integration)

---

## Core Features
- **macOS Oriented:** Designed strictly for macOS 14.0+ (`.macOS(.v14)`).
- **Accent-Color Aware:** Controls dynamically adapt to system or parent-level `.tint(_:)` / `.accentColor(_:)` styling without hardcoded values.
- **Dynamic Color Contrast:** High-contrast text color selector calculated via W3C relative luminance.
- **Zero Third-Party Dependencies:** 100% native SwiftUI and Swift Concurrency.

---

## Component Index & Reference

### 1. `UMUICapsuleButton` [NEW]
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

### 2. `UMUITextField` [NEW]
A text entry control featuring an optional leading label, custom rounded-rect styling with focus ring glow, secure entry support, and a non-blocking 0.3s debounced binding.

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
- **0.3s Debounce:** Local keystrokes update local state instantly for latency-free typing. Sychronization to `value` is debounced by `300ms` using Swift Concurrency.
- **Instant Sync:** Sychronizes immediately (bypassing debounce) on **Enter/Return**, **blur (losing focus)**, or **disappear (`onDisappear`)**.
- **Eye Toggle:** Retains keyboard focus on the field programmatically so typing is never interrupted when toggling password visibility.

---

### 3. `UMUINumberControl`
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

### 4. `UMUIAngleControl`
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

### 5. `UMUIPositionGrid`
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

#### UMUIPosition Enum Cases
`topLeft`, `top`, `topRight`, `left`, `center`, `right`, `bottomLeft`, `bottom`, `bottomRight`.

---

### 6. `UMUIRadioButton`
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

---

### 7. `UMUIMiniSwitch` & `UMUISmallSwitch`
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

### 8. `UMUISection`
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

### 9. `UMUITagBar`
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

### 10. `UMUITagEditor`
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

### 11. `UMUICheckerboard`
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

## 12. Helper Extensions

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
