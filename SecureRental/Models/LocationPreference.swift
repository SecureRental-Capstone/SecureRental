//
//  LocationPreference.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-19.
//

// LocationPreference.swift
import Foundation
import CoreLocation

struct LocationPreference: Codable {
    var latitude: Double
    var longitude: Double
    var radiusInKm: Double
    var consentGiven: Bool
}

class LocationPreferenceManager {
    static let shared = LocationPreferenceManager()
    private let key = "UserLocationPreference"
    
    func save(_ preference: LocationPreference) {
        if let data = try? JSONEncoder().encode(preference) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load() -> LocationPreference? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(LocationPreference.self, from: data)
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

