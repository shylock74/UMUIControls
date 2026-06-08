//
//  RoundedCorners.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//  Structured under strict formatting guidelines.
//

import SwiftUI

// Structure:  rounded corners
public struct RoundedCorners : Shape {
	// A custom shape permitting independent corner radiuses.
	
	public var topLeftRadius : CGFloat = 0.0 // The radius of the top-left corner
	public var topRightRadius : CGFloat = 0.0 // The radius of the top-right corner
	public var bottomLeftRadius : CGFloat = 0.0 // The radius of the bottom-left corner
	public var bottomRightRadius : CGFloat = 0.0 // The radius of the bottom-right corner
	
	public init (topLeftRadius : CGFloat = 0.0,
				 topRightRadius : CGFloat = 0.0,
				 bottomLeftRadius : CGFloat = 0.0,
				 bottomRightRadius : CGFloat = 0.0) {
		// Initializes the custom RoundedCorners shape.
		self.topLeftRadius = topLeftRadius
		self.topRightRadius = topRightRadius
		self.bottomLeftRadius = bottomLeftRadius
		self.bottomRightRadius = bottomRightRadius
	}

	public func path (in rect : CGRect) -> Path {
		// Generates the custom path mapping the rounded corners within a rect.
		var path = Path ()
		
		let w = rect.size.width
		let h = rect.size.height
		
		let tr = min (min (self.topRightRadius,
						   h / 2),
					  w / 2)
		let tl = min (min (self.topLeftRadius,
						   h / 2),
					  w / 2)
		let bl = min (min (self.bottomLeftRadius,
						   h / 2),
					  w / 2)
		let br = min (min (self.bottomRightRadius,
						   h / 2),
					  w / 2)
		
		path.move (to: CGPoint (x: w / 2.0,
								y: 0))
		path.addLine (to: CGPoint (x: w - tr,
								   y: 0))
		path.addArc (center: CGPoint (x: w - tr,
									  y: tr),
					 radius: tr,
					 startAngle: Angle (degrees: -90),
					 endAngle: Angle (degrees: 0),
					 clockwise: false)
		
		path.addLine (to: CGPoint (x: w,
								   y: h - br))
		path.addArc (center: CGPoint (x: w - br,
									  y: h - br),
					 radius: br,
					 startAngle: Angle (degrees: 0),
					 endAngle: Angle (degrees: 90),
					 clockwise: false)
		
		path.addLine (to: CGPoint (x: bl,
								   y: h))
		path.addArc (center: CGPoint (x: bl,
									  y: h - bl),
					 radius: bl,
					 startAngle: Angle (degrees: 90),
					 endAngle: Angle (degrees: 180),
					 clockwise: false)
		
		path.addLine (to: CGPoint (x: 0,
								   y: tl))
		path.addArc (center: CGPoint (x: tl,
									  y: tl),
					 radius: tl,
					 startAngle: Angle (degrees: 180),
					 endAngle: Angle (degrees: 270),
					 clockwise: false)
		path.closeSubpath ()
		
		return path
	}
}
