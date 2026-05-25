//
//  UMSmallSwitch.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m small switch
public struct UMSmallSwitch : View {
	// A small, highly-compact toggle switch helper layout view.
	
	public var label : String // Inline switch descriptive label text
	@Binding public var isOn : Bool // Binding tracking state
	
	public init (_ label : String,
				 isOn : Binding <Bool>) {
		// Initializes the UMSmallSwitch structure.
		self.label = label
		self._isOn = isOn
	}
	
	public var body : some View {
		// Bounded toggle body layout.
		Toggle (label,
				isOn: $isOn)
			.font (.caption)
			.controlSize (.small)
			.toggleStyle (.switch)
	}
}
