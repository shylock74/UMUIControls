//
//  UMUIRightObjectView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i right object view
@available(macOS 11.0, *)
public struct UMUIRightObjectView : ViewModifier {
	// A layout view modifier that right-aligns content inside a horizontal container.

	public var width : CGFloat? // The optional bounded width allocated for the right-aligned content

	public init (width : CGFloat? = nil) {
		// Initializes the UMUIRightObjectView.
		self.width = width
	}

	public func body (content : Content) -> some View {
		// Embeds the content in an HStack with a leading Spacer to achieve right alignment.
		HStack {
			Spacer ()
			content
		}
		.frame (width: width)
	}
}
