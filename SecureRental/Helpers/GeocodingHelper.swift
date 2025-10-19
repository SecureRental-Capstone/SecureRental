//
//  GeocodingHelper.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-19.
//

import Foundation
import CoreLocation

struct Coordinates {
    let latitude: Double
    let longitude: Double
}

class GeocodingHelper {
    
    static func getCoordinates(for address: String) async throws -> Coordinates {
        let geocoder = CLGeocoder()
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let location = placemarks?.first?.location else {
                    continuation.resume(throwing: NSError(
                        domain: "GeocodingError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No location found for address"]
                    ))
                    return
                }
                
                let coordinates = Coordinates(latitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude)
                continuation.resume(returning: coordinates)
            }
        }
    }
}
