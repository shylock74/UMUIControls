//
//  UMUIBindingHelpers.swift
//  UMUIControls
//
//  Binding adapters for models whose stored type differs from the one a
//  control edits: most numeric controls work in Double, many settings are Int.
//

import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
public extension Binding where Value == Int {
    /// The value as a `Double`, rounded back to the nearest integer on write.
    ///
    /// ```swift
    /// UMUINumberControl(title: "Max Lines", value: $settings.maxLines.umDouble, range: 1...5)
    /// ```
    var umDouble: Binding<Double> {
        Binding<Double>(
            get: { Double(wrappedValue) },
            set: { wrappedValue = Int($0.rounded()) }
        )
    }
}

@available(macOS 10.15, iOS 13.0, *)
public extension Binding {
    /// A non-optional binding over an optional value, reading `defaultValue` when
    /// the stored value is `nil`. Writing always stores a value.
    ///
    /// ```swift
    /// UMUINumberControl(title: "Left", value: $margins.leftP.umDefault(0.05), range: 0...0.5)
    /// ```
    func umDefault<Wrapped>(_ defaultValue: Wrapped) -> Binding<Wrapped> where Value == Wrapped? {
        Binding<Wrapped>(
            get: { wrappedValue ?? defaultValue },
            set: { wrappedValue = $0 }
        )
    }
}
