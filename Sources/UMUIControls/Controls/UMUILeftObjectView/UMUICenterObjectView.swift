//
//  UMUICenterObjectView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i center object view
@available(macOS 11.0, *)
public struct UMUICenterObjectView : ViewModifier {
	// A layout view modifier that center-aligns content horizontally.
	
	public var width : CGFloat? // The optional bounded width allocated for the centered content
	
	public init (width : CGFloat? = nil) {
		// Initializes the UMUICenterObjectView.
		self.width = width
	}
	
	@ViewBuilder
	func centeredContent (content : Content) -> some View {
		// Embeds the content in an HStack with leading and trailing Spacers to center it.
		HStack (spacing: 0) {
			Spacer (minLength: 0)
			content
			Spacer (minLength: 0)
		}
		.frame (width: width)
	}
	
	@ViewBuilder
	public func body (content : Content) -> some View {
		// The final body implementation applying the frame and alignment.
		if let width = width {
			centeredContent (content: content)
				.frame (width: width)
		} else {
			centeredContent (content: content)
		}
	}
}
