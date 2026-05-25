//
//  UMHSpacer.swift
//  UMUIControls
//
//  Created by Alex Raccuglia on 28/02/22.
//

import SwiftUI

/// A clean horizontal spacer helper drawing transparent blocks.
public struct UMHSpacer: View {
    public var width: CGFloat
    
    public init(_ width: CGFloat = 20) {
        self.width = width
    }
    
    public var body: some View {
        Color.clear.frame(width: width, height: 1)
    }
}

/// A clean vertical spacer helper drawing transparent blocks.
public struct UMVSpacer: View {
    public var height: CGFloat
    
    public init(_ height: CGFloat = 10) {
        self.height = height
    }
    
    public var body: some View {
        Color.clear.frame(width: 1, height: height)
    }
}
