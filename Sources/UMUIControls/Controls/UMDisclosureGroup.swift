//
//  UMDisclosureGroup.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 23/06/22.
//  Retrofitted for macOS 11.
//

import SwiftUI

// MARK: - UMDisclosureGroup
public struct UMDisclosureGroup<Content: View>: View {
    var title: String
    var smallFont: Bool = false
    @Binding var expanded: Bool
    var content: () -> Content
    
    public init(
        _ title: String,
        smallFont: Bool = false,
        expanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.smallFont = smallFont
        self._expanded = expanded
        self.content = content
    }
    
    public var body: some View {
        DisclosureGroup(title, isExpanded: $expanded) {
            UMVSpacer()
            content()
                .padding(.leading, 12)
        }
        .font(smallFont ? .caption : .body)
        .umRoundedBox()
    }
}

// MARK: - UMExpansionDisclosureGroup
public struct UMExpansionDisclosureGroup<Content: View>: View {
    var label: String?
    var postLabel: String?
    @Binding var title: String
    @Binding var expanded: Bool
    var backgroundColor: Color? = .boxGray
    var borderColor: Color = .clear
    var smallFont: Bool = false
    var content: () -> Content
    
    public init(
        label: String? = nil,
        title: Binding<String>,
        postLabel: String? = nil,
        expanded: Binding<Bool>,
        backgroundColor: Color? = .boxGray,
        borderColor: Color = .clear,
        smallFont: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.postLabel = postLabel
        self._title = title
        self._expanded = expanded
        self.content = content
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.smallFont = smallFont
    }
    
    public var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                if let label = label {
                    Text(label)
                        .font(smallFont ? .caption : .body)
                }
                UMTextFieldView(text: $title)
                if let postLabel = postLabel {
                    CaptionText(postLabel)
                }
                Image(systemName: "chevron.up")
                    .rotationEffect(Angle(degrees: expanded ? 0 : 180))
                    .onTapGesture {
                        withAnimation {
                            expanded.toggle()
                        }
                    }
            }
            if expanded {
                content()
            }
        }
        .umRoundedBox(backgroundColor: backgroundColor, borderColor: borderColor)
    }
}

// MARK: - UMSwitchExpansionDisclosureGroup
public struct UMSwitchExpansionDisclosureGroup<Content: View>: View {
    var label: String
    var smallFont: Bool = false
    @Binding var expanded: Bool
    var backgroundColor: Color?
    var content: () -> Content
    
    public init(
        label: String,
        smallFont: Bool = false,
        expanded: Binding<Bool>,
        backgroundColor: Color? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.smallFont = smallFont
        self._expanded = expanded
        self.content = content
        self.backgroundColor = backgroundColor ?? Color.gray.opacity(0.1)
    }
    
    public init(
        label: String,
        smallFont: Bool = false,
        expanded: Binding<Bool>,
        color: Color,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.smallFont = smallFont
        self._expanded = expanded
        self.content = content
        self.backgroundColor = color
    }
    
    public var body: some View {
        VStack {
            HStack(spacing: 2) {
                UMSmallSwitch(label, isOn: $expanded)
                Spacer(minLength: 0)
            }
            if expanded {
                UMVSpacer(6)
                VStack(alignment: .leading) {
                    content()
                }
            }
        }
        .umRoundedBox(backgroundColor: backgroundColor)
    }
}

// MARK: - UMExpansionDisclosureSGroup
public struct UMExpansionDisclosureSGroup<Content: View>: View {
    var label: String?
    var smallFont: Bool = false
    @Binding var expanded: Bool
    var content: () -> Content
    
    public init(
        label: String? = nil,
        smallFont: Bool = false,
        expanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.smallFont = smallFont
        self._expanded = expanded
        self.content = content
    }
    
    public init(
        _ label: String? = nil,
        smallFont: Bool = false,
        expanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.smallFont = smallFont
        self._expanded = expanded
        self.content = content
    }
    
    public var body: some View {
        VStack {
            HStack(spacing: 2) {
                if let label = label {
                    Text(label)
                        .font(smallFont ? .caption : .body)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.up")
                    .rotationEffect(Angle(degrees: expanded ? 0 : 180))
                    .onTapGesture {
                        withAnimation {
                            expanded.toggle()
                        }
                    }
            }
            if expanded {
                content()
            }
        }
        .umRoundedBox()
    }
}

// MARK: - UMGeneralDisclosureGroup
public struct UMGeneralDisclosureGroup<LabelContent: View, Content: View>: View {
    var label: () -> LabelContent
    @Binding var title: String
    @Binding var expanded: Bool
    var content: () -> Content
    
    public init(
        label: @escaping () -> LabelContent,
        title: Binding<String>,
        expanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self._title = title
        self._expanded = expanded
        self.content = content
    }
    
    public var body: some View {
        VStack {
            HStack(spacing: 2) {
                label()
                Image(systemName: "chevron.up")
                    .rotationEffect(Angle(degrees: expanded ? 0 : 180))
                    .onTapGesture {
                        withAnimation {
                            expanded.toggle()
                        }
                    }
            }
            if expanded {
                content()
            }
        }
        .umRoundedBox()
    }
}

// MARK: - Local Compatibility Helpers

/// A standard, self-contained small switch with an onChange callback helper.
struct UMSmallSwitch: View {
    let label: String
    @Binding var isOn: Bool
    
    init(_ label: String, isOn: Binding<Bool>) {
        self.label = label
        self._isOn = isOn
    }
    
    var body: some View {
        Toggle(label, isOn: $isOn)
            .font(.caption)
            .controlSize(.small)
            .toggleStyle(.switch)
    }
}

/// A standard backward-compatible text field wrapper.
struct UMTextFieldView: View {
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.roundedBorder)
    }
}

// MARK: - UMRoundedBox Modifier
public struct UMRoundedBoxModifier: ViewModifier {
    var backgroundColor: Color?
    var borderColor: Color?
    
    public func body(content: Content) -> some View {
        content
            .padding(8)
            .background(backgroundColor ?? Color.secondary.opacity(0.1))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor ?? Color.secondary.opacity(0.2), lineWidth: 0.5)
            )
    }
}

public extension View {
    func umRoundedBox(backgroundColor: Color? = nil, borderColor: Color? = nil) -> some View {
        self.modifier(UMRoundedBoxModifier(backgroundColor: backgroundColor, borderColor: borderColor))
    }
}
