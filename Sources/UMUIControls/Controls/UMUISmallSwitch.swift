//
//  UMUISmallSwitch.swift
//  UMUIControls
//
//  A small toggle switch with a caption-sized label.
//  Uses `.controlSize(.small)` for a compact but readable toggle.
//

import SwiftUI
import UMOmniaFramework

@available(macOS 11.0, *)
public struct UMUISmallSwitch: View {
	
	public enum Size {
		case normal
		case small
		case mini
	}
	
	var label :         String?
	var size :          Size
	@Binding var isOn : Bool
	
	var animate :       Bool
	var callback :      ((Bool) -> ())?
	
	var onColor : Color {
		UMAccentColorChecker.getAppAccentColor () ?? .red
	}
	
	var offColor : Color {
		if UMAccentColorChecker.getAppAccentColor () != nil {
			return .gray
		}
		return .red
	}
	
	var scale : CGFloat {
		switch size {
			case .normal:
				return 1
			case .small:
				return 0.75
			case .mini:
				return 0.65
		}
	}
	
	private let pressureQueue = UMPressureTask ()
	@State private var forceUpdate = false
	
	// Il parametro size ora ha come default .mini
	public init (_ label :  String? = nil,
				 isOn :     Binding <Bool>,
				 size :     Size =  .mini,
				 animate :  Bool =  true,
				 callback : ((Bool) -> ())? = nil) {
		self.label = label
		self.size = size
		self._isOn = isOn
		self.animate = animate
		self.callback = callback
	}
	
	public var body: some View {
		// HStack dispone gli elementi da sinistra a destra: Switch -> Testo
		HStack (spacing: 4) {
			
			// 1. Switch (Sinistra)
			ZStack {
				Color.buttonBackgroundGray
					.clipShape (RoundedRectangle (cornerRadius: 10))
					.scaleEffect (0.9)
				RoundedRectangle (cornerRadius: 10)
					.strokeBorder (Color.gray, lineWidth: 1)
					.scaleEffect (0.9)
				ZStack {
					Circle ()
						.foregroundColor (isOn ? onColor : offColor)
					Group {
						Image (systemName: "checkmark")
							.opacity (isOn ? 0.5 : 0)
						Image (systemName: "xmark")
							.opacity (isOn ? 0 : 0.5)
					}
					.foregroundColor (Color.white)
					.scaleEffect (scale * 0.8)
				}
				.frame (width: 16, height: 16)
				.offset (x : isOn ? 10 : -10, y: 0)
			}
			.frame (width: 40 * scale, height: 20 * scale)
			.scaleEffect (scale)
			
			// 2. Scritta (Destra)
			if let label {
				if size == .mini {
					CaptionText (label)
				} else {
					Text (label)
				}
			}
		}
		.animation (.easeInOut, value: isOn)
		.onTapGesture {
			isOn.toggle ()
			callback? (isOn)
		}
		.onChange (of: isOn) { newValue in
			forceUpdate.toggle ()
		}
	}
}

@available(macOS 11.0, *)
struct UMUISmallSwitch_Previews: PreviewProvider {
	@State static var isOn : Bool = false
	static var previews: some View {
		UMUISmallSwitch ("Testo", isOn : $isOn)
	}
}
