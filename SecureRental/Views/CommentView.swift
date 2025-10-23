
import SwiftUI

struct CommentView: View {
    var listing: Listing
    @EnvironmentObject var dbHelper: FireDBHelper
    @Environment(\.dismiss) private var dismiss
    
    @State private var comment: String = ""
    @State private var rating: Double = 0.0
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
                
                    // ⭐ Star Rating View
                VStack(spacing: 8) {
                    Text("Your Rating")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { index in
                            starView(for: index)
                                .font(.system(size: 35))
                                .foregroundColor(starColor(for: index))
                                .onTapGesture { handleStarTap(index: index) }
                        }
                    }
                    
                    Text(String(format: "%.1f", rating))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                    // 📝 Comment input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Please tell us about your experience")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("", text: $comment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                    // ✅ Submit button
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
    
        // MARK: - Star View Logic
    private func starView(for index: Int) -> Image {
        let threshold = Double(index)
        if rating >= threshold {
            return Image(systemName: "star.fill") // Full star
        } else if rating + 0.5 >= threshold {
            return Image(systemName: "star.leadinghalf.filled") // Half star
        } else {
            return Image(systemName: "star") // Empty star
        }
    }
    
    private func starColor(for index: Int) -> Color {
        let threshold = Double(index)
        if rating >= threshold || rating + 0.5 >= threshold {
            return .yellow
        } else {
            return .gray
        }
    }
    
    private func handleStarTap(index: Int) {
        let starValue = Double(index)
            // Detect half or full star taps by alternating between them
        if rating == starValue {
            rating = starValue - 0.5
        } else if rating == starValue - 0.5 {
            rating = starValue
        } else {
            rating = starValue
        }
    }
    
        // MARK: - Submit Logic
    private func submitComment() {
        guard rating >= 1 else {
            alertMessage = "Please select a rating between 1 and 5."
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
