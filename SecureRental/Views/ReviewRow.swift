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
            // Profile Image Placeholder
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(review.userName)
                        .font(.headline)
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
