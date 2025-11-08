//
//  SplashView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-11-07.
//
import SwiftUI

struct SplashView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.5
    @State private var settleDone = false
    @State private var showWelcome = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .animation(.easeOut(duration: 0.5), value: settleDone)
                
                 
                if showWelcome {
                    Text("Welcome to SecureRental")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.9), .purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                        .kerning(1)
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            )
                        )
                        .scaleEffect(1.02)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showWelcome)
                }
            }
        }
        .onAppear {
               
            withAnimation(.easeInOut(duration: 1.2)) {
                rotation = 360
                scale = 0.8
            }
            
         
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    scale = 1.0
                    settleDone = true
                }
            }
            
                // Step 3: Welcome message fade-in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.7)) {
                    showWelcome = true
                }
            }
        }
    }
}
