//
//  UMUISegmentedBar.swift
//  UMUIControls
//
//  A premium, visual segmented control bar featuring smooth hardware-accelerated
//  sliding capsule backdrops (via matchedGeometryEffect) for single selection,
//  and individual reactive glowing capsules for multi-selection.
//

import SwiftUI

/// Sizing modes for Segmented Controls.
@available(macOS 11.0, *)
public enum UMUISegmentedBarSize: Sendable, Equatable {
    case normal
    case small
}

/// Display modes for `UMUISegmentedBar`.
@available(macOS 11.0, *)
public enum UMUISegmentedBarMode: Sendable, Equatable {
    /// Automatically transforms into a picker when space is constrained and any title would truncate.
    case auto
    /// Always forces the segmented bar layout.
    case segmented
    /// Always forces the picker layout.
    case picker
}

/// A premium visual segmented bar for single selection of String options.
///
/// Features a sliding pill backdrop that glides smoothly behind selected options
/// using hardware-accelerated spring animations (`matchedGeometryEffect`).
/// Automatically collapses into a compact `UMUIPicker` if horizontal space is constrained
/// to prevent title truncation.
///
/// Usage:
/// ```swift
/// UMUISegmentedBar(label: "Layout", options: ["Left", "Center", "Right"], selection: $alignment, size: .normal)
/// ```
@available(macOS 11.0, *)
public struct UMUISegmentedBar: View {
    /// The optional label displayed on the leading edge.
    public let label: String?
    
    /// The array of options represented by the segmented control.
    public let options: [String]
    
    /// Binding to the currently selected string option.
    @Binding public var selection: String
    
    /// The sizing mode of the segmented control.
    public let size: UMUISegmentedBarSize
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    /// Mode controlling whether the bar transforms into a picker automatically.
    public let mode: UMUISegmentedBarMode
    
    @Namespace private var animationNamespace
    @State private var hoveredOption: String? = nil
    
    /// Creates a new single-selection segmented bar.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - options: Array of text choices.
    ///   - selection: Binding to the active selection.
    ///   - size: Sizing mode (default is `.normal`).
    ///   - labelWidth: Horizontal width reserved for label (default is `80`).
    ///   - mode: Display mode (default is `.auto`).
    public init(
        label: String? = nil,
        options: [String],
        selection: Binding<String>,
        size: UMUISegmentedBarSize = .small,
        labelWidth: CGFloat = 80,
        mode: UMUISegmentedBarMode = .auto
    ) {
        self.label = label
        self.options = options
        self._selection = selection
        self.size = size
        self.labelWidth = labelWidth
        self.mode = mode
    }
    
    private var optionFont: Font {
        return size == .normal ? .body.bold() : .caption.bold()
    }
    
    private var horizontalPadding: CGFloat {
        return size == .normal ? 24 : 18
    }
    
    private var verticalPadding: CGFloat {
        return size == .normal ? 7 : 5
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Optional Label
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(size == .normal ? .body : .caption)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }
            
            // Segment Deck or Picker Deck
            deckContent
        }
    }
    
    @ViewBuilder
    private var deckContent: some View {
        switch mode {
        case .segmented:
            segmentedDeck
        case .picker:
            pickerDeck
        case .auto:
            if #available(macOS 13.0, *) {
                ViewThatFits(in: .horizontal) {
                    segmentedDeck
                        .fixedSize(horizontal: true, vertical: false)
                    pickerDeck
                }
            } else {
                segmentedDeck
            }
        }
    }
    
    private var pickerDeck: some View {
        UMUIPicker(
            options: options,
            selection: $selection,
            size: size == .normal ? .normal : .small
        )
    }
    
    private var segmentedDeck: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.self) { option in
                Button {
                    // Spring glide transition
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.8)) {
                        selection = option
                    }
                } label: {
                    Text(option)
                        .font(optionFont)
                        .lineLimit(1)
                        .foregroundColor(selection == option ? Color.accentColor : Color.secondary)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                        .frame(minWidth: size == .normal ? 55 : 45)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .background(
                    // Sliding Capsule Backdrop
                    Group {
                        if selection == option {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.controlBackgroundColor))
                                .shadow(color: .black.opacity(0.12), radius: 1.5, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.secondary.opacity(0.1), lineWidth: 0.5)
                                )
                                .matchedGeometryEffect(id: "activeSegment", in: animationNamespace)
                        }
                    }
                )
                // Subtle hover overlay
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(hoveredOption == option && selection != option ? Color.primary.opacity(0.04) : Color.clear)
                )
                .onHover { hovering in
                    hoveredOption = hovering ? option : nil
                }
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 0.5)
        )
    }
}

// MARK: - Generic Enum Extension

@available(macOS 11.0, *)
extension UMUISegmentedBar {
    /// Creates a segmented bar bound to any `Hashable & CaseIterable` enum or collection.
    public init<T: Hashable & CaseIterable>(
        label: String? = nil,
        selection: Binding<T>,
        titleProvider: @escaping (T) -> String = { "\($0)" },
        size: UMUISegmentedBarSize = .small,
        labelWidth: CGFloat = 80,
        mode: UMUISegmentedBarMode = .auto
    ) {
        let stringOptions = Array(T.allCases).map { titleProvider($0) }
        let binding = Binding<String>(
            get: { titleProvider(selection.wrappedValue) },
            set: { newTitle in
                if let match = Array(T.allCases).first(where: { titleProvider($0) == newTitle }) {
                    selection.wrappedValue = match
                }
            }
        )
        self.init(
            label: label,
            options: stringOptions,
            selection: binding,
            size: size,
            labelWidth: labelWidth,
            mode: mode
        )
    }
}

// MARK: - Multi-Selection Segmented Bar

/// A premium visual segmented bar supporting multiple selection of String options inside a Set.
///
/// Toggle-based selection where each active option illuminates individually with a glowing capsule.
///
/// Usage:
/// ```swift
/// UMUIMultiSegmentedBar(label: "Attributes", options: ["Bold", "Italic", "Underline"], selection: $appliedStyles, size: .normal)
/// ```
@available(macOS 11.0, *)
public struct UMUIMultiSegmentedBar: View {
    /// The optional label displayed on the leading edge.
    public let label: String?
    
    /// The array of options represented by the segmented control.
    public let options: [String]
    
    /// Binding to the Set of currently selected options.
    @Binding public var selection: Set<String>
    
    /// The sizing mode of the segmented control.
    public let size: UMUISegmentedBarSize
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    @State private var hoveredOption: String? = nil
    
    /// Creates a new multi-selection segmented bar.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - options: Array of text choices.
    ///   - selection: Binding to the active Set of selections.
    ///   - size: Sizing mode (default is `.normal`).
    ///   - labelWidth: Horizontal width reserved for label (default is `80`).
    public init(
        label: String? = nil,
        options: [String],
        selection: Binding<Set<String>>,
        size: UMUISegmentedBarSize = .small,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self.options = options
        self._selection = selection
        self.size = size
        self.labelWidth = labelWidth
    }
    
    private var optionFont: Font {
        return size == .normal ? .body.bold() : .caption.bold()
    }
    
    private var horizontalPadding: CGFloat {
        return size == .normal ? 24 : 18
    }
    
    private var verticalPadding: CGFloat {
        return size == .normal ? 7 : 5
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Optional Label
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(size == .normal ? .body : .caption)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }
            
            // Segment Deck Container
            HStack(spacing: 2) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selection.contains(option)
                    
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                            if isSelected {
                                selection.remove(option)
                            } else {
                                selection.insert(option)
                            }
                        }
                    } label: {
                        Text(option)
                            .font(optionFont)
                            .lineLimit(1)
                            .foregroundColor(isSelected ? Color.accentColor : Color.secondary)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                            .frame(minWidth: size == .normal ? 55 : 45)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .background(
                        // Individual active backgrounds
                        Group {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color( .controlBackgroundColor))
                                    .shadow(color: .black.opacity(0.12), radius: 1.5, y: 1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.accentColor.opacity(0.15), lineWidth: 0.5)
                                    )
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    )
                    // Subtle hover overlay
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(hoveredOption == option && !isSelected ? Color.primary.opacity(0.04) : Color.clear)
                    )
                    .onHover { hovering in
                        hoveredOption = hovering ? option : nil
                    }
                }
            }
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUISegmentedBar_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var singleSelection = "Center"
        @State private var multiSelection = Set<String>(["Bold"])
        
        var body: some View {
            VStack(spacing: 25) {
                Text("Segmented Bar Previews")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Single Selection Normal:")
                        .font(.subheadline).foregroundColor(.secondary)
                    
                    UMUISegmentedBar(
                        label: "Alignment",
                        options: ["Left", "Center", "Right"],
                        selection: $singleSelection,
                        size: .normal
                    )
                    
                    Divider()
                    
                    Text("Multi Selection Small:")
                        .font(.subheadline).foregroundColor(.secondary)
                    
                    UMUIMultiSegmentedBar(
                        label: "Text Style",
                        options: ["Bold", "Italic", "Underline"],
                        selection: $multiSelection,
                        size: .small
                    )
                }
                
                Divider()
                
                // Monitor
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Active Alignment:")
                            .font(.caption2).bold()
                        Spacer()
                        Text(singleSelection)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Color.accentColor)
                    }
                    HStack {
                        Text("Active Styles:")
                            .font(.caption2).bold()
                        Spacer()
                        Text(multiSelection.sorted().joined(separator: ", "))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
            .padding(30)
            .frame(width: 380)
        }
    }
    
    static var previews: some View {
        TestWrapper()
    }
}
#endif
