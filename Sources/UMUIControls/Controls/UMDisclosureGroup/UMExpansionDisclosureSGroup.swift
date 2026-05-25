//
//  UMExpansionDisclosureSGroup.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m expansion disclosure s group
public struct UMExpansionDisclosureSGroup <Content : View> : View {
	// A sleek, minimal custom expansion card using an arrow indicator header.
	
	public var label : String? // Optional title segment label text
	public var smallFont : Bool // Standard visual compact mode indicator
	@Binding public var expanded : Bool // Binding tracking expansion state
	public var content : () -> Content // Trailing closure content
	
	public init (label : String? = nil,
				 smallFont : Bool = false,
				 expanded : Binding <Bool>,
				 @ViewBuilder content : @escaping () -> Content) {
		// Initializes the UMExpansionDisclosureSGroup view.
		self.label = label
		self.smallFont = smallFont
		self._expanded = expanded
		self.content = content
	}
	
	public init (_ label : String? = nil,
				 smallFont : Bool = false,
				 expanded : Binding <Bool>,
				 @ViewBuilder content : @escaping () -> Content) {
		// Convenience initializer placing label text in a single argument signature.
		self.label = label
		self.smallFont = smallFont
		self._expanded = expanded
		self.content = content
	}
	
	public var body : some View {
		// Interactive container body segment.
		VStack {
			HStack (spacing: 2) {
				if let label = label {
					Text (label)
						.font (smallFont ? .caption : .body)
				}
				Spacer (minLength: 0)
				Image (systemName: "chevron.up")
					.rotationEffect (Angle (degrees: expanded ? 0 : 180))
					.onTapGesture {
						withAnimation {
							expanded.toggle ()
						}
					}
			}
			if expanded {
				content ()
			}
		}
		.umRoundedBox ()
	}
}
