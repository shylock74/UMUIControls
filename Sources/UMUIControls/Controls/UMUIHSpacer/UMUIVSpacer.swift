//
//  UMUIVSpacer.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 28/02/22.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i v spacer
public struct UMUIVSpacer : View {
	// A clean vertical spacer helper drawing transparent blocks.
	
	public var height : CGFloat // Bounded height of the vertical spacer block
	
	public init (_ height : CGFloat = 10) {
		// Initializes the UMUIVSpacer.
		self.height = height
	}
	
	public var body : some View {
		// Bounded body visual layout.
		Color.clear.frame (width: 1,
						   height: height)
	}
}
