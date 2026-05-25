//
//  UMTextFieldView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m text field view
public struct UMTextFieldView : View {
	// A simple, backward-compatible text field wrapper struct.
	
	@Binding public var text : String // Binding to the target input string value
	public var placeholder : String // Text field placeholder visual description text
	
	public init (text : Binding <String>,
				 placeholder : String = "") {
		// Initializes the UMTextFieldView structure.
		self._text = text
		self.placeholder = placeholder
	}
	
	public var body : some View {
		// Standardized text field body layout.
		TextField (placeholder,
				   text: $text)
			.textFieldStyle (.roundedBorder)
	}
}
