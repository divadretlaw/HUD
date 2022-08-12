//
//  View.swift
//  HUD
//
//  Created by David Walter on 07.08.22.
//

import SwiftUI

struct HUDView<Content>: View where Content: View {
    var content: () -> Content
    
    // Used to animate the appearance
    @State private var isShowing = false
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                if isShowing {
                    content()
                        .transition(.opacity.combined(with: .scale(scale: 1.1)))
                }
                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                isShowing = true
            }
        }
    }
}
