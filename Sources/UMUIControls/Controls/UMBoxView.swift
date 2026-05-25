//
//  UMBoxView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 16/09/21.
//

import SwiftUI

/// A beautiful container box drawing a filled background and continuous stroke border.
public struct UMBoxView: View {
    public var cornerRadius: CGFloat
    public var borderWidth: CGFloat
    public var backColor: Color?
    public var foreColor: Color
    
    public init(
        cornerRadius: CGFloat = 10,
        borderWidth: CGFloat = 2,
        backColor: Color? = nil,
        foreColor: Color
    ) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.backColor = backColor
        self.foreColor = foreColor
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(backColor ?? foreColor)
                .opacity(backColor != nil ? 1 : 0.25)
            RoundedRectangle(
                cornerRadius: cornerRadius,
                style: .continuous
            )
            .stroke(lineWidth: borderWidth)
            .foregroundColor(foreColor)
        }
    }
}
