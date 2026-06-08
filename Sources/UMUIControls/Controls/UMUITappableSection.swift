//
//  UMUITappableSection.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i tappable section
public struct UMUITappableSection <Content : View> : View {
	// A custom section container that toggles its expanded state when tapped.
	
	public var title : String // Header title string of the tappable section
	@Binding public var open : Bool // Binding to track the expansion open state
	public var content : () -> Content // Trailing closure content builder
	
	public init (_ title : String,
				 open : Binding <Bool>,
				 @ViewBuilder content : @escaping () -> Content) {
		// Initializes the UMUITappableSection view.
		self.title = title
		self._open = open
		self.content = content
	}
	
	public var body : some View {
		// Bounded body visual structure using UMUISection.
		UMUISection (title) {
			Group {
				if open {
					content ()
						.allowsHitTesting (true)
				} else {
					EmptyView ()
						.frame (height: 1)
				}
			}
		}
		.contentShape (Rectangle ())
		.onTapGesture {
			withAnimation {
				open.toggle ()
			}
		}
	}
}
