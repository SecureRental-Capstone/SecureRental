//
//  MapLocation.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-04.
//

import Foundation
import CoreLocation

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
