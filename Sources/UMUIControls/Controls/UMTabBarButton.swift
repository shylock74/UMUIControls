//
//  UMTabBarButton.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 06/05/24.
//  Retrofitted for macOS 11.
//

import SwiftUI

public struct UMTabBarUIView: View {
    
    public struct LabelAndId: Identifiable, Equatable {
        public var id: String
        public var label: String
        public var icon: String?

        public init(
            id: String,
            label: String,
            icon: String? = nil
        ) {
            self.id = id
            self.label = label
            self.icon = icon
        }
    }
    
    var labelAndIds: [LabelAndId]
    @Binding var selectedId: String
    var selectedColor: Color = .mildDarkGray
    
    public init(
        labelAndIds: [LabelAndId],
        selectedId: Binding<String>,
        selectedColor: Color = .mildDarkGray
    ) {
        self.labelAndIds = labelAndIds
        self._selectedId = selectedId
        self.selectedColor = selectedColor
    }
    
    public var body: some View {
        HStack(spacing: 1) {
            ForEach(labelAndIds.indices, id: \.self) { i in
                UMTabBarButton(
                    label: labelAndIds[i].label,
                    iconName: labelAndIds[i].icon,
                    id: labelAndIds[i].id,
                    location: i == 0 ? .leading : (i == labelAndIds.count - 1 ? .trailing : .center),
                    selectedColor: selectedColor,
                    selectedId: $selectedId
                )
            }
        }
    }
}

public struct UMTabBarButton: View {
    
    public enum Location {
        case leading
        case center
        case trailing
    }
    
    var label: String
    var iconName: String?
    var id: String
    var location: Location = .center
    var selectedColor: Color
    var horizontalPadding: CGFloat
    @Binding var selectedId: String
        
    public init(
        label: String,
        iconName: String? = nil,
        id: String,
        location: Location = .leading,
        selectedColor: Color = .mildDarkGray,
        horizontalPadding: CGFloat = 8,
        selectedId: Binding<String>
    ) {
        self.label = label
        self.iconName = iconName
        self.id = id
        self.location = location
        self.selectedColor = selectedColor
        self._selectedId = selectedId
        self.horizontalPadding = horizontalPadding
    }

    let padding: CGFloat = 4
    let normalRadius: CGFloat = 3
    let borderRadius: CGFloat = 8
    
    func bg() -> some View {
        switch location {
        case .leading:
            return RoundedCorners(
                topLeftRadius: borderRadius,
                topRightRadius: normalRadius,
                bottomLeftRadius: borderRadius,
                bottomRightRadius: normalRadius
            )
        case .center:
            return RoundedCorners(
                topLeftRadius: normalRadius,
                topRightRadius: normalRadius,
                bottomLeftRadius: normalRadius,
                bottomRightRadius: normalRadius
            )
        case .trailing:
            return RoundedCorners(
                topLeftRadius: normalRadius,
                topRightRadius: borderRadius,
                bottomLeftRadius: normalRadius,
                bottomRightRadius: borderRadius
            )
        }
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            if let iconName = iconName {
                Image(systemName: iconName)
            }
            Text(label)
        }
        .padding(.horizontal, 4 + horizontalPadding)
        .padding(padding)
        .background(
            bg()
                .foregroundColor(selectedId == id ? selectedColor : Color.darkGray)
        )
        .onTapGesture {
            withAnimation {
                selectedId = id
            }
        }
    }
}

struct RoundedCorners: Shape {
    var topLeftRadius: CGFloat = 0.0
    var topRightRadius: CGFloat = 0.0
    var bottomLeftRadius: CGFloat = 0.0
    var bottomRightRadius: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        let tr = min(min(self.topRightRadius, h/2), w/2)
        let tl = min(min(self.topLeftRadius, h/2), w/2)
        let bl = min(min(self.bottomLeftRadius, h/2), w/2)
        let br = min(min(self.bottomRightRadius, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(
            center: CGPoint(x: w - tr, y: tr),
            radius: tr,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(
            center: CGPoint(x: w - br, y: h - br),
            radius: br,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(
            center: CGPoint(x: bl, y: h - bl),
            radius: bl,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(
            center: CGPoint(x: tl, y: tl),
            radius: tl,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}
