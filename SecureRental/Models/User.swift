import Foundation

class AppUser: ObservableObject, Identifiable, Codable {
    var id: String                // Firebase UID
    var username: String
    var email: String
    var name: String
    var profilePictureURL: String?
    var rating: Double               // 1 to 5
    var reviews: [String]         // Multiple reviews
    var favoriteListingIDs: [String] = []
    
    // New properties
    var locationConsent: Bool? = nil // nil means not asked yet
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    // initialization
    init(
        id: String = UUID().uuidString,
        username: String,
        email: String,
        name: String,
        profilePictureURL: String? = nil,
        rating: Double = 0.0,
        reviews: [String] = [],
        favoriteListingIDs: [String] = []
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.name = name
        self.profilePictureURL = profilePictureURL
        self.rating = rating
        self.reviews = reviews
        self.favoriteListingIDs = favoriteListingIDs
    }
    
    static let sampleUser = AppUser(
        id: "sample-uid-123",
        username: "janedoe123",
        email: "janedoe@example.com",
        name: "Jane Doe",
        profilePictureURL: "https://example.com/avatar.jpg",
        rating: 4,
        reviews: [
            "Great landlord!",
            "Very responsive and helpful.",
            "Would rent again."
        ]
    )
}
