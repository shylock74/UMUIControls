//
//  UMTopObjectView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m top object view
public struct UMTopObjectView : ViewModifier {
	// A layout view modifier that top-aligns content inside a vertical container.
	
	public init () {
		// Initializes the UMTopObjectView.
	}
	
	@ViewBuilder
	public func body (content : Content) -> some View {
		// Embeds the content in a VStack with a trailing Spacer to achieve top alignment.
		VStack {
			content
			Spacer (minLength: 0)
		}
	}
}
