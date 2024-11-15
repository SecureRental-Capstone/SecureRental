//
//  CommentView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-14.
//

import SwiftUI

struct CommentView: View {
    var listing: RentalListing
    @State private var comment: String = ""
    @State private var rating: Double = 1.0 // Rating from 1 to 5
    var viewModel: RentalListingsViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Rate or Comment on \(listing.title)")
                    .font(.headline)
                    .padding()

                // Rating slider
//                Slider(value: $rating, in: 1...5, step: 1)
//                    .padding()
//                Text("Rating: \(rating)")
                Slider(value: $rating, in: 1...5, step: 1.0) // Change step to 1.0
                                    .padding()
                Text("Rating: \(Int(rating))")

                // Comment text field
                TextField("Enter your comment", text: $comment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Save button
                Button("Submit") {
//                    viewModel.addComment(to: listing, comment: comment)
//                    viewModel.addRating(to: listing, rating: rating)
                    // Dismiss the view
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .navigationTitle("Comment & Rate")
            .padding()
        }
    }
}
