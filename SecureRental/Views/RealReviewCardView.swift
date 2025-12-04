//
//  RealReviewCardView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-11-24.
//
import SwiftUI

struct RealReviewCardView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .top) {
                
                    //  Initial Circle
                Text(String(review.userName.prefix(1)).uppercased())
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.purple.opacity(0.8))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    
                      
                    HStack {
                        Text(review.userName)
                            .font(.headline)
                        


                        
                        Spacer()
                    }
                    
                        //  Date
                    Text(formattedDate(review.timestamp))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                    //  Stars
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(review.rating.rounded()) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
            
                //  Comment
            Text(review.comment)
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
    }
    

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}
