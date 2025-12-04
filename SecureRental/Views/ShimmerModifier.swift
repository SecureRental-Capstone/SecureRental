//
//  ShimmerModifier.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-11-14.
//


import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.6),
                        Color.white.opacity(0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(15))
                .offset(x: phase)
                .blendMode(.plusLighter)
                .mask(content)
            }
            .onAppear {
                withAnimation(
                    .linear(duration: 1.3)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 250   // move gradient across the view
                }
            }
    }
}

import SwiftUI


extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}
