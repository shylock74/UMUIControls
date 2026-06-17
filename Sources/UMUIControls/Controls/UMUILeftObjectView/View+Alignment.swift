//
//  View+Alignment.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

@available(macOS 11.0, *)
public extension View {
	/// Left-aligns this view inside its parent container.
	func left (_ width : CGFloat? = nil) -> some View {
		self.modifier (UMUILeftObjectView (width: width))
	}
	
	/// Horizontally centers this view inside its parent container.
	func centered () -> some View {
		self.modifier (UMUICenterObjectView ())
	}
	
	/// Horizontally centers this view inside its parent container.
	func hCentered () -> some View {
		self.modifier (UMUICenterObjectView ())
	}
	
	/// Vertically centers this view inside its parent container.
	func zCentered () -> some View {
		self.modifier (UMUIZCenterObjectView ())
	}
	
	/// Vertically centers this view inside its parent container.
	func vCentered () -> some View {
		self.modifier (UMUIZCenterObjectView ())
	}
}
