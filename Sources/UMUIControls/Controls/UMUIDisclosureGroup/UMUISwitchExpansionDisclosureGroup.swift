//
//  UMUISwitchExpansionDisclosureGroup.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i switch expansion disclosure group
@available(macOS 11.0, *)
public struct UMUISwitchExpansionDisclosureGroup <Content : View> : View {
	// A disclosure card where expansion state is controlled directly via a small Switch toggle.
	
	public var label : String // Button switch inline descriptive title label
	public var smallFont : Bool // Compact size font toggle flag
	@Binding public var expanded : Bool // Binding tracking expansion toggle state
	public var backgroundColor : Color? // Bounding box backdrop color
	public var content : () -> Content // Trailing closure content
	
	public init (label : String,
				 smallFont : Bool = false,
				 expanded : Binding <Bool>,
				 backgroundColor : Color? = nil,
				 @ViewBuilder content : @escaping () -> Content) {
		// Initializes the UMUISwitchExpansionDisclosureGroup component.
		self.label = label
		self.smallFont = smallFont
		self._expanded = expanded
		self.content = content
		self.backgroundColor = backgroundColor ?? Color.gray.opacity (0.1)
	}
	
	public init (label : String,
				 smallFont : Bool = false,
				 expanded : Binding <Bool>,
				 color : Color,
				 @ViewBuilder content : @escaping () -> Content) {
		// Alternate initializer specifying an explicit backdrop highlight color.
		self.label = label
		self.smallFont = smallFont
		self._expanded = expanded
		self.content = content
		self.backgroundColor = color
	}
	
	public var body : some View {
		// Bounded body visual structure.
		VStack {
			HStack (spacing: 2) {
				UMUISmallSwitch (label,
								 isOn: $expanded)
				Spacer (minLength: 0)
			}
			if expanded {
				UMUIVSpacer (6)
				VStack (alignment: .leading) {
					content ()
				}
			}
		}
		.umRoundedBox (backgroundColor: backgroundColor)
	}
}
