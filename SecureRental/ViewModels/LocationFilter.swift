//
//  LocationFilter.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-04.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class LocationFilter: ObservableObject {
    @Published var radiusInKm: Double = 5.0
    @Published var customLocation: CLLocation?
    
    var effectiveLocation: CLLocation? {
        customLocation
    }
}
