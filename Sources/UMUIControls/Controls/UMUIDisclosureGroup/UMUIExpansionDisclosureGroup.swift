//
//  UMUIExpansionDisclosureGroup.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i expansion disclosure group
@available(macOS 11.0, *)
public struct UMUIExpansionDisclosureGroup <Content : View> : View {
	// A disclosure card featuring an inline text field as its header.
	
	public var label : String? // Optional label positioned left of the input field
	public var postLabel : String? // Optional caption suffix placed right of the input field
	@Binding public var title : String // Binding targeting the header text input
	@Binding public var expanded : Bool // Binding tracking expansion state
	public var backgroundColor : Color? // Bounding box backdrop color
	public var borderColor : Color // Boundary line outline color
	public var smallFont : Bool // Standard compact font styling flag
	public var content : () -> Content // Trailing closure content
	
	public init (label : String? = nil,
				 title : Binding <String>,
				 postLabel : String? = nil,
				 expanded : Binding <Bool>,
				 backgroundColor : Color? = .boxGray,
				 borderColor : Color = .clear,
				 smallFont : Bool = false,
				 @ViewBuilder content : @escaping () -> Content) {
		// Initializes the UMUIExpansionDisclosureGroup component.
		self.label = label
		self.postLabel = postLabel
		self._title = title
		self._expanded = expanded
		self.content = content
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
		self.smallFont = smallFont
	}
	
	public var body : some View {
		// The interactive body segment.
		VStack {
			HStack (alignment: .firstTextBaseline,
					spacing: 4) {
				if let label = label {
					Text (label)
						.font (smallFont ? .caption : .body)
				}
				UMUITextFieldView (text: $title)
				if let postLabel = postLabel {
					CaptionText (postLabel)
				}
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
		.umRoundedBox (backgroundColor: backgroundColor,
					   borderColor: borderColor)
	}
}
