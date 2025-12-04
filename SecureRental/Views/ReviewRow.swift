//
//  ReviewRow.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-10-23.
//


import SwiftUI

struct ReviewRow: View {
    let review: Review
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            if let urlString = review.profilePictureURL,
                           !urlString.isEmpty,
                           let url = URL(string: urlString) {
                            
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                    
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    
                                case .failure:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                        } else {
                            // DEFAULT AVATAR
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(review.userName)
                        .font(.headline)
                    
                    if review.isVerified == true {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))
                                                .font(.caption2)
                                            Text("Verified")
                                                .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))
                                                .font(.caption2)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.12))
                                        .cornerRadius(6)
                                    }
                    Spacer()
                    Text(review.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Star Rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(review.rating.rounded()) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text(review.comment)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
