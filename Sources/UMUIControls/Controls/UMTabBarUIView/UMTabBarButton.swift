//
//  UMTabBarButton.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 06/05/24.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m tab bar button
public struct UMTabBarButton : View {
	// A single selectable tab button component in the tab bar.
	
	public enum Location {
		// Defines the relative visual position of the tab button in the tab bar.
		case leading
		case center
		case trailing
	}
	
	public var label : String // Button label text
	public var iconName : String? // Optional system icon name
	public var id : String // Unique identifier for the button
	public var location : Location // The horizontal boundary position
	public var selectedColor : Color // The active selection highlight color
	public var horizontalPadding : CGFloat // Custom horizontal padding
	@Binding public var selectedId : String // Binding to the global active tab id
		
	public init (label : String,
				 iconName : String? = nil,
				 id : String,
				 location : Location = .leading,
				 selectedColor : Color = .mildDarkGray,
				 horizontalPadding : CGFloat = 8,
				 selectedId : Binding <String>) {
		// Initializes a single tab button.
		self.label = label
		self.iconName = iconName
		self.id = id
		self.location = location
		self.selectedColor = selectedColor
		self._selectedId = selectedId
		self.horizontalPadding = horizontalPadding
	}

	public var padding : CGFloat = 4 // Base padding around content
	public var normalRadius : CGFloat = 3 // Subtle corner radius for inner edges
	public var borderRadius : CGFloat = 8 // Outer boundary corner radius
	
	func bg () -> some View {
		// Builds the background shape according to the tab location.
		switch location {
			case .leading :
				return RoundedCorners (topLeftRadius: borderRadius,
									   topRightRadius: normalRadius,
									   bottomLeftRadius: borderRadius,
									   bottomRightRadius: normalRadius)
			case .center :
				return RoundedCorners (topLeftRadius: normalRadius,
									   topRightRadius: normalRadius,
									   bottomLeftRadius: normalRadius,
									   bottomRightRadius: normalRadius)
			case .trailing :
				return RoundedCorners (topLeftRadius: normalRadius,
									   topRightRadius: borderRadius,
									   bottomLeftRadius: normalRadius,
									   bottomRightRadius: borderRadius)
		}
	}
	
	public var body : some View {
		// The interactive body of the tab button.
		HStack (spacing: 4) {
			if let iconName = iconName {
				Image (systemName: iconName)
			}
			Text (label)
		}
		.padding (.horizontal,
				  4 + horizontalPadding)
		.padding (padding)
		.background (bg ()
			.foregroundColor (selectedId == id ? selectedColor : Color.darkGray))
		.onTapGesture {
			withAnimation {
				selectedId = id
			}
		}
	}
}
