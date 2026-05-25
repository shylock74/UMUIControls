//
//  View+Alignment.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

public extension View {
	/// Left-aligns this view inside its parent container.
	func leftObject (_ width : CGFloat? = nil) -> some View {
		self.modifier (UMLeftObjectView (width: width))
	}
	
	/// Horizontally centers this view inside its parent container.
	func umCentered () -> some View {
		self.modifier (UMCenterObjectView ())
	}
	
	/// Vertically centers this view inside its parent container.
	func umZCentered () -> some View {
		self.modifier (UMZCenterObjectView ())
	}
}
