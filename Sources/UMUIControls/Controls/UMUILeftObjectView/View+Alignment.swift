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
	func umLeft (_ width : CGFloat? = nil) -> some View {
		self.modifier (UMUILeftObjectView (width: width))
	}
	
	/// Horizontally centers this view inside its parent container.
	func umCentered () -> some View {
		self.modifier (UMUICenterObjectView ())
	}
	
	/// Horizontally centers this view inside its parent container.
	func umHCentered () -> some View {
		self.modifier (UMUICenterObjectView ())
	}
	
	/// Vertically centers this view inside its parent container.
	func umZCentered () -> some View {
		self.modifier (UMUIZCenterObjectView ())
	}
	
	/// Vertically centers this view inside its parent container.
	func umVCentered () -> some View {
		self.modifier (UMUIZCenterObjectView ())
	}
}
