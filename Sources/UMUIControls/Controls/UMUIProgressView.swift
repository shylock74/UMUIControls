import SwiftUI
import Combine

/// Defines the visual configuration for the custom progress wheel.
/// It allows customizing the tint color and adapts seamlessly to different sizes.
@available(macOS 11.0, *)
public struct UMUIProgressViewStyle {
	/// The primary color of the progress indicators. Defaults to gray if nil, falls back to accentColor.
	public var tintColor : Color?
	
	/// Public initializer to allow external configuration of the style.
	/// - Parameter tintColor: An optional custom color for the wheels.
	public init (tintColor : Color? = nil) {
		self.tintColor = tintColor
	}
}

/// A custom indeterminate progress indicator featuring concentric animated wheels.
/// This view contains strictly graphical components and no text elements.
@available(macOS 11.0, *)
public struct UMUIProgressView : View {
	/// The visual configuration style containing color preferences.
	public var style : UMUIProgressViewStyle
	
	/// The current rotation angle driven by the animation timer.
	@State private var rotationAngle : Angle = .degrees (0)
	
	/// Public initializer to create the progress wheel with a specific style.
	/// - Parameter style: The style configuration, defaults to a standard instance.
	public init (style : UMUIProgressViewStyle = UMUIProgressViewStyle ()) {
		self.style = style
	}
	
	/// The body definition of the SwiftUI View.
	public var body : some View {
		GeometryReader { geometry in
			let size = min (
				geometry.size.width,
				geometry.size.height
			)
			let baseColor = style.tintColor ?? Color.gray
			
			// Dynamically adjust stroke width based on the allocated view size
			let outerStroke = size > 24 ? 3.0 : 1.5
			let innerStroke = size > 24 ? 2.0 : 1.0
			
			ZStack {
				// Outer Wheel background shadow ring
				Circle ()
					.stroke (
						baseColor.opacity (0.2),
						lineWidth : outerStroke
					)
				
				// Outer Wheel active rotating segment
				Circle ()
					.trim (
						from : 0.0,
						to : 0.3
					)
					.stroke (
						baseColor,
						style : StrokeStyle (
							lineWidth : outerStroke,
							lineCap : .round
						)
					)
					.rotationEffect (rotationAngle)
				
				// Inner Wheel active rotating segment (rotating in opposite direction)
				Circle ()
					.trim (
						from : 0.0,
						to : 0.4
					)
					.stroke (
						baseColor.opacity (0.7),
						style : StrokeStyle (
							lineWidth : innerStroke,
							lineCap : .round
						)
					)
					.padding (size * 0.25)
					.rotationEffect (-rotationAngle * 1.5)
			}
			.frame (
				width : size,
				height : size
			)
			.position (
				x : geometry.size.width / 2,
				y : geometry.size.height / 2
			)
		}
		.onAppear {
			// Initiates a continuous, linear rotation animation that bypasses UI thread blockages
			withAnimation (
				.linear (duration : 2.0)
				.repeatForever (autoreverses : false)
			) {
				rotationAngle = .degrees (360)
			}
		}
	}
}
