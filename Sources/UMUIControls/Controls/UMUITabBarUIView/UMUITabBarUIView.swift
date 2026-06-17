//
//  UMUITabBarUIView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 06/05/24.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i tab bar u i view
@available(macOS 11.0, *)
public struct UMUITabBarUIView : View {
	// A horizontal tab bar that manages the selection of tabs.

	public struct LabelAndId : Identifiable, Equatable {
		// A model representing a tab with an identifier, a label, and an optional icon.
		
		public var id : String // Unique identifier for the tab
		public var label : String // Title of the tab
		public var icon : String? // Optional SF Symbol name for the tab

		public init (id : String,
					 label : String,
					 icon : String? = nil) {
			// Initializes a LabelAndId instance.
			self.id = id
			self.label = label
			self.icon = icon
		}
	}
	
	public var labelAndIds : [LabelAndId] // Array of tab models to display
	@Binding public var selectedId : String // Binding to the active selected tab id
	public var selectedColor : Color // The highlight color applied to the selected tab
	
	public init (labelAndIds : [LabelAndId],
				 selectedId : Binding <String>,
				 selectedColor : Color = .accentColor) {
		// Initializes the UMUITabBarUIView with labels, selection binding, and an optional selected color.
		self.labelAndIds = labelAndIds
		self._selectedId = selectedId
		self.selectedColor = selectedColor
	}
	
	public var body : some View {
		// The visual body containing the horizontal sequence of tab buttons.
		HStack (spacing: 20) {
			ForEach (labelAndIds.indices,
					 id: \.self) { i in
				UMUITabBarButton (label: labelAndIds [i].label,
								  iconName: labelAndIds [i].icon,
								  id: labelAndIds [i].id,
								  selectedColor: selectedColor,
								  selectedId: $selectedId)
			}
		}
	}
}
