//
//  UMTabBarUIView.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 06/05/24.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m tab bar u i view
public struct UMTabBarUIView : View {
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
				 selectedColor : Color = .mildDarkGray) {
		// Initializes the UMTabBarUIView with labels, selection binding, and an optional selected color.
		self.labelAndIds = labelAndIds
		self._selectedId = selectedId
		self.selectedColor = selectedColor
	}
	
	public var body : some View {
		// The visual body containing the horizontal sequence of tab buttons.
		HStack (spacing: 1) {
			ForEach (labelAndIds.indices,
					 id: \.self) { i in
				UMTabBarButton (label: labelAndIds [i].label,
								iconName: labelAndIds [i].icon,
								id: labelAndIds [i].id,
								location: i == 0 ? .leading : (i == labelAndIds.count - 1 ? .trailing : .center),
								selectedColor: selectedColor,
								selectedId: $selectedId)
			}
		}
	}
}
