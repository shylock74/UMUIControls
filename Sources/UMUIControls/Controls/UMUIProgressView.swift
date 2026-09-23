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
	
	/// The current rotation angle for the outer wheel. Only used on macOS 11, see body.
	@State private var outerRotationAngle : Angle = .degrees (0)
	
	/// The current rotation angle for the inner wheel. Only used on macOS 11, see body.
	@State private var innerRotationAngle : Angle = .degrees (0)
	
	/// Seconds for one full turn of the outer wheel.
	private static let outerPeriod : Double = 2.0
	
	/// Seconds for one full turn of the inner wheel, in the opposite direction
	/// (Questo mantiene il rapporto di velocità di circa 1.5x rispetto a quello esterno)
	private static let innerPeriod : Double = 1.33
	
	/// Public initializer to create the progress wheel with a specific style.
	/// - Parameter style: The style configuration, defaults to a standard instance.
	public init (style : UMUIProgressViewStyle = UMUIProgressViewStyle ()) {
		self.style = style
	}
	
	/// The body definition of the SwiftUI View.
	///
	/// The angles are read off the clock rather than animated. A repeatForever animation started from
	/// onAppear becomes the transaction of that whole update, so whatever else changes layout in the same
	/// pass — a sheet resizing to fit this view, a sibling appearing — is animated by it too, and keeps
	/// repeating long after this view is gone. A TimelineView has no transaction to lend.
	public var body : some View {
		if #available (macOS 12.0, *) {
			TimelineView (.animation) { context in
				let seconds = context.date.timeIntervalSinceReferenceDate
				wheels (
					outerAngle : .degrees (seconds.truncatingRemainder (dividingBy : Self.outerPeriod) / Self.outerPeriod * 360),
					innerAngle : .degrees (-seconds.truncatingRemainder (dividingBy : Self.innerPeriod) / Self.innerPeriod * 360)
				)
			}
		} else {
			wheels (
				outerAngle : outerRotationAngle,
				innerAngle : innerRotationAngle
			)
			.onAppear {
				// Outer circle animation: 1 full rotation every 2 seconds
				withAnimation (
					.linear (duration : Self.outerPeriod)
					.repeatForever (autoreverses : false)
				) {
					outerRotationAngle = .degrees (360)
				}
				
				// Inner circle animation: 1 full rotation in the opposite direction every 1.33 seconds
				withAnimation (
					.linear (duration : Self.innerPeriod)
					.repeatForever (autoreverses : false)
				) {
					innerRotationAngle = .degrees (-360)
				}
			}
		}
	}
	
	/// The two concentric wheels at the given angles, sized to the space offered.
	private func wheels (outerAngle : Angle, innerAngle : Angle) -> some View {
		GeometryReader { geometry in
			let size = min (
				geometry.size.width,
				geometry.size.height
			)
			let baseColor = style.tintColor ?? Color.gray
			
			// Dynamically adjust stroke width based on the allocated view size.
			// When there is room, the strokes grow with the view and the inner wheel moves closer to the outer one,
			// leaving the middle free (e.g. for a percentage label laid over it).
			let isRoomy = size >= 48
			let outerStroke = isRoomy ? min (size * 0.07, 8.0) : (size > 24 ? 3.0 : 1.5)
			let innerStroke = isRoomy ? outerStroke * 2.0 / 3.0 : (size > 24 ? 2.0 : 1.0)
			let innerInset = size * (isRoomy ? 0.15 : 0.25)

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
					.rotationEffect (outerAngle)
				
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
					.padding (innerInset)
					.rotationEffect (innerAngle)
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
		.frame (maxWidth : .infinity, maxHeight : .infinity)
	}
}
