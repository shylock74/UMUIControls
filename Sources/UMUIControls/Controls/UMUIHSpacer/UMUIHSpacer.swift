//
//  UMUIHSpacer.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 28/02/22.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i h spacer
@available(macOS 11.0, *)
public struct UMUIHSpacer : View {
	// A clean horizontal spacer helper drawing transparent blocks.
	
	public var width : CGFloat // Bounded width of the horizontal spacer block
	
	public init (_ width : CGFloat = 20) {
		// Initializes the UMUIHSpacer.
		self.width = width
	}
	
	public var body : some View {
		// Bounded body visual layout.
		Color.clear.frame (width: width,
						   height: 1)
	}
}
