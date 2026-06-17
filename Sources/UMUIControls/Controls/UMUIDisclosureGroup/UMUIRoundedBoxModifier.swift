//
//  UMUIRoundedBoxModifier.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i rounded box modifier
@available(macOS 11.0, *)
public struct UMUIRoundedBoxModifier : ViewModifier {
	// A custom view modifier drawing standard rounded grouping borders and glassy backgrounds.
	
	public var backgroundColor : Color? // Bounding box container background color override
	public var borderColor : Color? // Boundary line stroke outline color override
	
	public init (backgroundColor : Color? = nil,
				 borderColor : Color? = nil) {
		// Initializes the UMUIRoundedBoxModifier.
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
	}
	
	public func body (content : Content) -> some View {
		// Draws the glassy bounding grouping card.
		content
			.padding (8)
			.background (backgroundColor ?? Color.secondary.opacity (0.1))
			.cornerRadius (6)
			.overlay (RoundedRectangle (cornerRadius: 6)
				.stroke (borderColor ?? Color.secondary.opacity (0.2),
						 lineWidth: 0.5))
	}
}

@available(macOS 11.0, *)
public extension View {
	/// Enfolds a SwiftUI view within a standardized premium rounded box.
	func umRoundedBox (backgroundColor : Color? = nil,
					   borderColor : Color? = nil) -> some View {
		self.modifier (UMUIRoundedBoxModifier (backgroundColor: backgroundColor,
											   borderColor: borderColor))
	}
}
