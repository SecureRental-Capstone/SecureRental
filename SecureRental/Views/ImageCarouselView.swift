//
//  ImageCorouselView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//

import SwiftUI

struct CarouselView: View {
    var imageURLs: [String]
    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<imageURLs.count, id: \.self) { index in
                    AsyncImage(url: URL(string: imageURLs[index])) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .cornerRadius(10)
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .foregroundColor(.black)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 300)
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = .opaqueSeparator
                UIPageControl.appearance().pageIndicatorTintColor = .darkGray
            }

            if currentIndex > 0 {
                Button(action: {
                    withAnimation { currentIndex -= 1 }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black.opacity(0.7))
                }
                .position(x: 30, y: 150)
            }

            if currentIndex < imageURLs.count - 1 {
                Button(action: {
                    withAnimation { currentIndex += 1 }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black.opacity(0.7))
                }
                .position(x: UIScreen.main.bounds.width - 30, y: 150)
            }
        }
    }
}
