//
//  UMUIDisclosureGroup.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 23/06/22.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i disclosure group
public struct UMUIDisclosureGroup <Content : View> : View {
	// A custom expandable disclosure group view component.
	
	public var title : String // Header title string of the disclosure group
	public var smallFont : Bool // Flag indicating whether to use small caption font styling
	@Binding public var expanded : Bool // Binding to track the expansion state of the group
	public var content : () -> Content // Trailing closure containing the content of the group
	
	public init (_ title : String,
				 smallFont : Bool = false,
				 expanded : Binding <Bool>,
				 @ViewBuilder content : @escaping () -> Content) {
		// Initializes the UMUIDisclosureGroup structure.
		self.title = title
		self.smallFont = smallFont
		self._expanded = expanded
		self.content = content
	}
	
	public var body : some View {
		// The interactive body of the disclosure group.
		DisclosureGroup (title,
						 isExpanded: $expanded) {
			UMUIVSpacer ()
			content ()
				.padding (.leading,
						  12)
		}
		.font (smallFont ? .caption : .body)
		.umRoundedBox ()
	}
}
