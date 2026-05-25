//
//  UMZCenterObjectView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m z center object view
public struct UMZCenterObjectView : ViewModifier {
	// A layout view modifier that centers content vertically.
	
	public init () {
		// Initializes the UMZCenterObjectView.
	}
	
	@ViewBuilder
	public func body (content : Content) -> some View {
		// Embeds the content in a VStack with leading and trailing Spacers to center it vertically.
		VStack {
			Spacer (minLength: 0)
			content
			Spacer (minLength: 0)
		}
	}
}
