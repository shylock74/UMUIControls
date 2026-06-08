//
//  UMUITopObjectView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i top object view
public struct UMUITopObjectView : ViewModifier {
	// A layout view modifier that top-aligns content inside a vertical container.
	
	public init () {
		// Initializes the UMUITopObjectView.
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
