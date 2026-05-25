//
//  UMTappableSection.swift
//  UMUIControls
//
//  Created by Alex Raccuglia.
//

import SwiftUI

/// A custom section container that toggles its expanded state when tapped.
public struct UMTappableSection<Content: View>: View {
    public var title: String
    @Binding public var open: Bool
    public var content: () -> Content
    
    public init(
        _ title: String,
        open: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._open = open
        self.content = content
    }
    
    public var body: some View {
        UMUISection(title) {
            Group {
                if open {
                    content()
                        .allowsHitTesting(true)
                } else {
                    EmptyView()
                        .frame(height: 1)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                open.toggle()
            }
        }
    }
}
