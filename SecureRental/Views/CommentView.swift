////
////  CommentView.swift
////  SecureRental
////
////  Created by Anchal  Sharma  on 2024-11-14.
////
//
//import SwiftUI
//
//struct CommentView: View {
//    var listing: Listing
//    @State private var comment: String = ""
//    @State private var rating: Double = 1.0 // Rating from 1 to 5
//    var viewModel: RentalListingsViewModel
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("Rate or Comment on \(listing.title)")
//                    .font(.headline)
//                    .padding()
//
//                // Rating slider
//                Slider(value: $rating, in: 1...5, step: 1.0) // Change step to 1.0
//                                    .padding()
//                Text("Rating: \(Int(rating))")
//
//                // Comment text field
//                TextField("Enter your comment", text: $comment)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//
//                // Save button
//                Button("Submit") {
////                    viewModel.addComment(to: listing, comment: comment)
////                    viewModel.addRating(to: listing, rating: rating)
//                    // Dismiss the view
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//
//                Spacer()
//            }
//            .navigationTitle("Comment & Rate")
//            .padding()
//        }
//    }
//}
    //
    //  CommentView.swift
    //  SecureRental
    //
    //  Created by Anchal Sharma on 2024-11-14.
    //
    //
    //  CommentView.swift
    //  SecureRental
    //
    //  Created by Anchal Sharma on 2024-11-14.
    //

import SwiftUI

struct CommentView: View {
    var listing: Listing
    @EnvironmentObject var dbHelper: FireDBHelper
    @Environment(\.dismiss) private var dismiss
    
    @State private var comment: String = ""
    @State private var ratingText: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Rate and Comment on")
                    .font(.headline)
                
                Text(listing.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                    // Rating input field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Rating (1 - 5)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Enter rating (e.g., 3.5)", text: $ratingText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                    // Comment input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Comment")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Write your comment here...", text: $comment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                    // Submit button
                Button(action: submitComment) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Comment & Rate")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
        // MARK: - Submit logic
    private func submitComment() {
        guard let rating = Double(ratingText), rating >= 1, rating <= 5 else {
            alertMessage = "Please enter a valid rating between 1 and 5."
            showAlert = true
            return
        }
        
        guard !comment.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter a comment."
            showAlert = true
            return
        }
        
        guard let user = dbHelper.currentUser else { return }
        
        dbHelper.addReview(to: listing, rating: rating, comment: comment, user: user)
        dismiss()
    }

}
