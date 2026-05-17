//
//  UMUISegmentedBar.swift
//  UMUIControls
//
//  A premium, visual segmented control bar featuring smooth hardware-accelerated
//  sliding capsule backdrops (via matchedGeometryEffect) for single selection,
//  and individual reactive glowing capsules for multi-selection.
//

import SwiftUI

/// A premium visual segmented bar for single selection of String options.
///
/// Features a sliding pill backdrop that glides smoothly behind selected options
/// using hardware-accelerated spring animations (`matchedGeometryEffect`).
///
/// Usage:
/// ```swift
/// UMUISegmentedBar(label: "Layout", options: ["Left", "Center", "Right"], selection: $alignment)
/// ```
public struct UMUISegmentedBar: View {
    /// The optional label displayed on the leading edge.
    public let label: String?
    
    /// The array of options represented by the segmented control.
    public let options: [String]
    
    /// Binding to the currently selected string option.
    @Binding public var selection: String
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    @Namespace private var animationNamespace
    @State private var hoveredOption: String? = nil
    
    /// Creates a new single-selection segmented bar.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - options: Array of text choices.
    ///   - selection: Binding to the active selection.
    ///   - labelWidth: Horizontal width reserved for label (default is `80`).
    public init(
        label: String? = nil,
        options: [String],
        selection: Binding<String>,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self.options = options
        self._selection = selection
        self.labelWidth = labelWidth
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Optional Label
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }
            
            // Segment Deck Container
            HStack(spacing: 2) {
                ForEach(options, id: \.self) { option in
                    Button {
                        // Spring glide transition
                        withAnimation(.spring(response: 0.26, dampingFraction: 0.8)) {
                            selection = option
                        }
                    } label: {
                        Text(option)
                            .font(.caption)
                            .bold()
                            .foregroundStyle(selection == option ? Color.accentColor : Color.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .frame(minWidth: 45)
                            .contentShape(Rectangle())
                            .background(
                                // Sliding Capsule Backdrop
                                Group {
                                    if selection == option {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(nsColor: .controlBackgroundColor))
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
                    }
                    .buttonStyle(.plain)
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

// MARK: - Multi-Selection Segmented Bar

/// A premium visual segmented bar supporting multiple selection of String options inside a Set.
///
/// Toggle-based selection where each active option illuminates individually with a glowing capsule.
///
/// Usage:
/// ```swift
/// UMUIMultiSegmentedBar(label: "Attributes", options: ["Bold", "Italic", "Underline"], selection: $appliedStyles)
/// ```
public struct UMUIMultiSegmentedBar: View {
    /// The optional label displayed on the leading edge.
    public let label: String?
    
    /// The array of options represented by the segmented control.
    public let options: [String]
    
    /// Binding to the Set of currently selected options.
    @Binding public var selection: Set<String>
    
    /// The width allocated for the optional leading label.
    public let labelWidth: CGFloat
    
    @State private var hoveredOption: String? = nil
    
    /// Creates a new multi-selection segmented bar.
    /// - Parameters:
    ///   - label: Optional leading label text.
    ///   - options: Array of text choices.
    ///   - selection: Binding to the active Set of selections.
    ///   - labelWidth: Horizontal width reserved for label (default is `80`).
    public init(
        label: String? = nil,
        options: [String],
        selection: Binding<Set<String>>,
        labelWidth: CGFloat = 80
    ) {
        self.label = label
        self.options = options
        self._selection = selection
        self.labelWidth = labelWidth
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Optional Label
            if let label = label {
                HStack(spacing: 0) {
                    Text(label)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
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
                            .font(.caption)
                            .bold()
                            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .frame(minWidth: 45)
                            .contentShape(Rectangle())
                            .background(
                                // Individual active backgrounds
                                Group {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(nsColor: .controlBackgroundColor))
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
                    }
                    .buttonStyle(.plain)
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
struct UMUISegmentedBar_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var singleSelection = "Center"
        @State private var multiSelection = Set<String>(["Bold"])
        
        var body: some View {
            VStack(spacing: 25) {
                Text("Segmented Bar Previews")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Single Selection (Gliding Pill)")
                        .font(.subheadline).foregroundStyle(.secondary)
                    
                    UMUISegmentedBar(
                        label: "Alignment",
                        options: ["Left", "Center", "Right"],
                        selection: $singleSelection
                    )
                    
                    Divider()
                    
                    Text("Multi Selection (Individual Slots)")
                        .font(.subheadline).foregroundStyle(.secondary)
                    
                    UMUIMultiSegmentedBar(
                        label: "Text Style",
                        options: ["Bold", "Italic", "Underline"],
                        selection: $multiSelection
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
                            .foregroundStyle(Color.accentColor)
                    }
                    HStack {
                        Text("Active Styles:")
                            .font(.caption2).bold()
                        Spacer()
                        Text(multiSelection.sorted().joined(separator: ", "))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(Color.accentColor)
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
