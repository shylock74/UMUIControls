//
//  UMUILeftObjectView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 25/08/21.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i left object view
public struct UMUILeftObjectView : ViewModifier {
	// A layout view modifier that left-aligns content inside a horizontal container.
	
	public var width : CGFloat? // The optional bounded width allocated for the left-aligned content
	
	public init (width : CGFloat? = nil) {
		// Initializes the UMUILeftObjectView.
		self.width = width
	}
	
	@ViewBuilder
	func leftedContent (content : Content) -> some View {
		// Embeds the content in an HStack with a trailing Spacer to achieve left alignment.
		HStack {
			content
			Spacer ()
		}
		.frame (width: width)
	}
	
	@ViewBuilder
	public func body (content : Content) -> some View {
		// The final body implementation applying the frame and alignment.
		if let width = width {
			leftedContent (content: content)
				.frame (width: width)
		} else {
			leftedContent (content: content)
		}
	}
}
