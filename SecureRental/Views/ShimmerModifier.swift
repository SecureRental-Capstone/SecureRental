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
//
///// A simple wrap layout for chips (like tags/amenities).
//struct FlexibleView<Item: Hashable, Content: View>: View {
//    let data: [Item]
//    let spacing: CGFloat
//    let alignment: HorizontalAlignment
//    let content: (Item) -> Content
//
//    init(
//        data: [Item],
//        spacing: CGFloat = 8,
//        alignment: HorizontalAlignment = .leading,
//        @ViewBuilder content: @escaping (Item) -> Content
//    ) {
//        self.data = data
//        self.spacing = spacing
//        self.alignment = alignment
//        self.content = content
//    }
//
//    var body: some View {
//        GeometryReader { geometry in
//            generateContent(in: geometry)
//        }
//    }
//
//    private func generateContent(in geometry: GeometryProxy) -> some View {
//        var currentX: CGFloat = 0
//        var currentY: CGFloat = 0
//
//        return ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
//            ForEach(data, id: \.self) { item in
//                content(item)
//                    .alignmentGuide(.leading) { dimension in
//                        // Wrap to next line if exceeding width
//                        if currentX + dimension.width > geometry.size.width {
//                            currentX = 0
//                            currentY -= (dimension.height + spacing)
//                        }
//                        let result = currentX
//                        currentX += dimension.width + spacing
//                        return result
//                    }
//                    .alignmentGuide(.top) { _ in
//                        let result = currentY
//                        return result
//                    }
//            }
//        }
//    }
//}
//

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}
