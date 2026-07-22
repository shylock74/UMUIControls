//
//  UMUIFrameExtensions.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 22/07/26.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  u m width
@available(macOS 10.15, iOS 13.0, *)
public struct UMWidth: ViewModifier {
	// A view modifier that sets a fixed width on a view with non-negative validation.
	public var width: CGFloat
	
	public init(width: CGFloat) {
		self.width = width
	}
	
	@ViewBuilder
	public func body(content: Content) -> some View {
		content.frame(width: max(width, 0))
	}
}

// Structure:  u m height
@available(macOS 10.15, iOS 13.0, *)
public struct UMHeight: ViewModifier {
	// A view modifier that sets a fixed height on a view with non-negative validation.
	public var height: CGFloat
	
	public init(height: CGFloat) {
		self.height = height
	}
	
	@ViewBuilder
	public func body(content: Content) -> some View {
		content.frame(height: max(height, 0))
	}
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
	/// Sets an explicit width on the view if non-nil.
	@ViewBuilder
	func width(_ w: CGFloat?) -> some View {
		if let w = w {
			self.modifier(UMWidth(width: w))
		} else {
			self
		}
	}
	
	/// Sets a maximum width on the view.
	func width(max width: CGFloat) -> some View {
		self.frame(maxWidth: width)
	}
	
	/// Sets a minimum width on the view.
	func width(min width: CGFloat) -> some View {
		self.frame(minWidth: width)
	}
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
	/// Sets an explicit height on the view if non-nil.
	@ViewBuilder
	func height(_ height: CGFloat?) -> some View {
		if let height = height {
			self.modifier(UMHeight(height: height))
		} else {
			self
		}
	}
	
	/// Sets a maximum height on the view.
	func height(max height: CGFloat) -> some View {
		self.frame(maxHeight: height)
	}
	
	/// Sets a minimum height on the view.
	func height(min height: CGFloat) -> some View {
		self.frame(minHeight: height)
	}
	
	/// Sets both minimum and maximum heights on the view.
	func height(min: CGFloat, max: CGFloat) -> some View {
		self.frame(minHeight: min, maxHeight: max)
	}
}

@available(macOS 10.15, iOS 13.0, *)
public extension View {
	/// Sets explicit width and height dimensions with validation.
	func rect(_ w: CGFloat, _ h: CGFloat) -> some View {
		let width: CGFloat = (w < 1 || w.isNaN) ? 1 : w
		let height: CGFloat = (h < 1 || h.isNaN) ? 1 : h
		return self.frame(width: width, height: height)
	}
	
	/// Sets fixed width and minimum height with validation.
	func rect(_ w: CGFloat, min h: CGFloat) -> some View {
		let width: CGFloat = (w < 1 || w.isNaN) ? 1 : w
		let height: CGFloat = (h < 1 || h.isNaN) ? 1 : h
		return self
			.width(width)
			.frame(minHeight: height)
	}
	
	/// Sets fixed width and maximum height with validation.
	func rect(_ w: CGFloat, max h: CGFloat) -> some View {
		let width: CGFloat = (w < 1 || w.isNaN) ? 1 : w
		let height: CGFloat = (h < 1 || h.isNaN) ? 1 : h
		return self
			.width(width)
			.frame(maxHeight: height)
	}
	
	/// Sets minimum width and fixed height with validation.
	func rect(min width: CGFloat, _ height: CGFloat) -> some View {
		self
			.frame(minWidth: width)
			.height(height)
	}
	
	/// Sets minimum width and minimum height.
	func rect(min width: CGFloat, min height: CGFloat) -> some View {
		self.frame(minWidth: width, minHeight: height)
	}
	
	/// Sets explicit size dimensions using CGSize if non-nil.
	@ViewBuilder
	func rect(size: CGSize?) -> some View {
		Group {
			if let size = size {
				self.frame(width: size.width, height: size.height)
			} else {
				self
			}
		}
	}
	
	/// Sets equal width and height (square layout).
	func side(_ s: CGFloat) -> some View {
		self.rect(s, s)
	}
}
