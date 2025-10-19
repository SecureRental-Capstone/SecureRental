import Foundation
class AppUser: ObservableObject, Identifiable, Codable {
    var id: String
    var username: String
    var email: String
    var name: String
    var profilePictureURL: String?
    var rating: Double
    var reviews: [String]
    var favoriteListingIDs: [String] = []

    // ✅ Add location preferences
    var locationConsent: Bool = false
    var latitude: Double?
    var longitude: Double?
    var preferredRadius: Double? = 2.0 // in km

    init(
        id: String = UUID().uuidString,
        username: String,
        email: String,
        name: String,
        profilePictureURL: String? = nil,
        rating: Double = 0.0,
        reviews: [String] = [],
        favoriteListingIDs: [String] = [],
        locationConsent: Bool = false,
        latitude: Double? = nil,
        longitude: Double? = nil,
        preferredRadius: Double? = 2.0
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.name = name
        self.profilePictureURL = profilePictureURL
        self.rating = rating
        self.reviews = reviews
        self.favoriteListingIDs = favoriteListingIDs
        self.locationConsent = locationConsent
        self.latitude = latitude
        self.longitude = longitude
        self.preferredRadius = preferredRadius
    }
}
