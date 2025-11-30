//
//  VerifyIdentityView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-30.
import SwiftUI

struct VerifyIdentityCard: View {
    var onVerify: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                // Circle with warning icon
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.93, blue: 0.6))
                        .frame(width: 40, height: 40)
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Verify Your Identity")
                        .font(.headline)
                        .fontWeight(.none)
                        .foregroundColor(.black)

                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal")
                                .foregroundColor(Color.gray)
                            Text("Post listings")
                                .foregroundColor(Color.gray)
                                .font(.subheadline)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "shield")
                                .foregroundColor(Color.gray)
                            Text("Build trust with users")
                                .foregroundColor(Color.gray)
                                .font(.subheadline)
                        }
                    }
                }
            }.lineSpacing(15)

            
            Button(action: onVerify) {
                Text("Verify Now")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
