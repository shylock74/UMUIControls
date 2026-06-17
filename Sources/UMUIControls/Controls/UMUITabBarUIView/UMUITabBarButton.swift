//
//  UMUITabBarButton.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 06/05/24.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i tab bar button
@available(macOS 11.0, *)
public struct UMUITabBarButton : View {
	// A single selectable tab button component in the tab bar.
	
	public var label : String // Button label text
	public var iconName : String? // Optional system icon name
	public var id : String // Unique identifier for the button
	public var selectedColor : Color // The active selection highlight color
	@Binding public var selectedId : String // Binding to the global active tab id
		
	public init (label : String,
				 iconName : String? = nil,
				 id : String,
				 selectedColor : Color = .accentColor,
				 selectedId : Binding <String>) {
		// Initializes a single tab button.
		self.label = label
		self.iconName = iconName
		self.id = id
		self.selectedColor = selectedColor
		self._selectedId = selectedId
	}
	
	private var isSelected : Bool {
		// Whether this button is the currently selected tab.
		selectedId == id
	}
	
	public var body : some View {
		// The interactive body of the tab button.
		Button {
			withAnimation {
				selectedId = id
			}
		} label: {
			HStack (spacing: 6) {
				if let iconName = iconName {
					Image (systemName: iconName)
						.font (.system (size: 11))
				}
				Text (label)
					.font (.system (size: 11,
									weight: isSelected ? .bold : .medium))
			}
			.padding (.horizontal, 10)
			.padding (.vertical, 6)
			.foregroundColor (isSelected ? selectedColor : .secondary)
			.background (isSelected ? selectedColor.opacity (0.1) : Color.clear)
			.clipShape (Capsule ())
		}
		.buttonStyle (.plain)
	}
}
