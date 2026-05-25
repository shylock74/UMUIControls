//
//  UMGeneralDisclosureGroup.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m general disclosure group
public struct UMGeneralDisclosureGroup <LabelContent : View, Content : View> : View {
	// An expandable card grouping container permitting custom ViewBuilder header segments.
	
	public var label : () -> LabelContent // ViewBuilder custom header title block
	@Binding public var title : String // Binding to the structural heading value
	@Binding public var expanded : Bool // Binding tracking open/collapsed state
	public var content : () -> Content // Trailing closure content
	
	public init (label : @escaping () -> LabelContent,
				 title : Binding <String>,
				 expanded : Binding <Bool>,
				 @ViewBuilder content : @escaping () -> Content) {
		// Initializes the UMGeneralDisclosureGroup component.
		self.label = label
		self._title = title
		self._expanded = expanded
		self.content = content
	}
	
	public var body : some View {
		// The interactive general body layout.
		VStack {
			HStack (spacing: 2) {
				label ()
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
