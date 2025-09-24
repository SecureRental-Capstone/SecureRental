import Foundation

struct AppUser: Identifiable, Codable {
    var id: String                // Firebase UID
    var username: String
    var email: String
    var name: String
    var profilePictureURL: String?
    var rating: Int               // 1 to 5
    var reviews: [String]         // Multiple reviews
    
    // initialization
    init(
        id: String = UUID().uuidString,
        username: String,
        email: String,
        name: String,
        profilePictureURL: String? = nil,
        rating: Int = 0,
        reviews: [String] = []
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.name = name
        self.profilePictureURL = profilePictureURL
        self.rating = rating
        self.reviews = reviews
    }
}
