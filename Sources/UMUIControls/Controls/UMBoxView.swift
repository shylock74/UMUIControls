//
//  UMBoxView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 16/09/21.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m box view
public struct UMBoxView : View {
	// A beautiful container box drawing a filled background and continuous stroke border.
	
	public var cornerRadius : CGFloat // Bounded corner radius size in points
	public var borderWidth : CGFloat // Bounded boundary line stroke outline width
	public var backColor : Color? // Bounding box backdrop background color override
	public var foreColor : Color // Structural front outline and highlight stroke color
	
	public init (cornerRadius : CGFloat = 10,
				 borderWidth : CGFloat = 2,
				 backColor : Color? = nil,
				 foreColor : Color) {
		// Initializes the UMBoxView component.
		self.cornerRadius = cornerRadius
		self.borderWidth = borderWidth
		self.backColor = backColor
		self.foreColor = foreColor
	}
	
	public var body : some View {
		// Bounded body visual layout.
		ZStack {
			RoundedRectangle (cornerRadius: cornerRadius)
				.foregroundColor (backColor ?? foreColor)
				.opacity (backColor != nil ? 1 : 0.25)
			RoundedRectangle (cornerRadius: cornerRadius,
							  style: .continuous)
				.stroke (lineWidth: borderWidth)
				.foregroundColor (foreColor)
		}
	}
}
