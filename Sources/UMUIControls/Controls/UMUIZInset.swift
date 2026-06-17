//
//  UMUIZInset.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 25/09/21.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m u i z inset
@available(macOS 11.0, *)
public struct UMUIZInset : ViewModifier {
	// A layout view modifier that positions content toward a specific corner or edge.
	
	public enum Corner {
		// Bounded positioning corner locations.
		case upperLeft
		case upperRight
		case lowerLeft
		case lowerRight
		case left
		case bottom
		case top
		
		func left () -> Bool {
			// Checks if the corner resides on the left edge.
			return self == .upperLeft || self == .lowerLeft || self == .left
		}
		
		func right () -> Bool {
			// Checks if the corner resides on the right edge.
			return self == .upperRight || self == .lowerRight
		}
		
		func upper () -> Bool {
			// Checks if the corner resides on the top edge.
			return self == .upperLeft || self == .upperRight || self == .top
		}
		
		func lower () -> Bool {
			// Checks if the corner resides on the bottom edge.
			return self == .lowerLeft || self == .lowerRight || self == .bottom
		}
	}
	
	public var corner : Corner // The structural corner placement for insetting content
	
	public init (corner : Corner = .upperLeft) {
		// Initializes the UMUIZInset modifier with a target corner.
		self.corner = corner
	}
	
	@ViewBuilder
	func inset (content : Content) -> some View {
		// Embeds the content in dynamic spacers to align it according to the target corner.
		HStack (spacing: 2) {
			if corner.right () {
				Spacer (minLength: 0)
			}
			VStack {
				if corner.lower () {
					Spacer (minLength: 0)
				}
				content
				if corner.upper () {
					Spacer (minLength: 0)
				}
			}
			if corner.left () {
				Spacer (minLength: 0)
			}
		}
	}
	
	@ViewBuilder
	public func body (content : Content) -> some View {
		// The standard body implementation of the view modifier.
		inset (content: content)
	}
}

@available(macOS 11.0, *)
public extension View {
	/// Insets this view toward the specified corner of its container.
	func zInset (corner : UMUIZInset.Corner = .upperLeft) -> some View {
		self.modifier (UMUIZInset (corner: corner))
	}
	
	/// Insets this view toward the specified corner of its container.
	func zInset (_ corner : UMUIZInset.Corner = .upperLeft) -> some View {
		self.modifier (UMUIZInset (corner: corner))
	}
}
