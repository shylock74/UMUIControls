//
//  UMUIZCenterObjectView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i z center object view
@available(macOS 11.0, *)
public struct UMUIZCenterObjectView : ViewModifier {
	// A layout view modifier that centers content vertically.
	
	public init () {
		// Initializes the UMUIZCenterObjectView.
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
