//
//  UMUICenter.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 01/10/21.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i center
@available(macOS 11.0, *)
public struct UMUICenter : ViewModifier {
	// A centering utility view modifier that centers content horizontally, vertically, or both.
	
	public enum Direction {
		// Bounded horizontal or vertical centering direction enums.
		case horizontally
		case vertically
		case both
	}
	
	public var direction : Direction // The active targeting layout alignment direction
	
	public init (direction : Direction = .horizontally) {
		// Initializes the UMUICenter modifier.
		self.direction = direction
	}
	
	@ViewBuilder
	public func body (content : Content) -> some View {
		// Embeds the content in appropriate alignment frames according to direction.
		if direction == .horizontally {
			content
				.frame (maxWidth: .infinity,
						alignment: .center)
		} else if direction == .vertically {
			content
				.frame (maxHeight: .infinity,
						alignment: .center)
		} else {
			content
				.frame (maxWidth: .infinity,
						maxHeight: .infinity,
						alignment: .center)
		}
	}
}

@available(macOS 11.0, *)
public extension View {
	/// Center a view horizontally, vertically, or in both directions.
	func umCenter (_ direction : UMUICenter.Direction = .horizontally) -> some View {
		self.modifier (UMUICenter (direction: direction))
	}
}
