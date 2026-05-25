//
//  UMVSpacer.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 28/02/22.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m v spacer
public struct UMVSpacer : View {
	// A clean vertical spacer helper drawing transparent blocks.
	
	public var height : CGFloat // Bounded height of the vertical spacer block
	
	public init (_ height : CGFloat = 10) {
		// Initializes the UMVSpacer.
		self.height = height
	}
	
	public var body : some View {
		// Bounded body visual layout.
		Color.clear.frame (width: 1,
						   height: height)
	}
}
