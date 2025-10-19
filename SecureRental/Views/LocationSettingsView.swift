//
//  LocationSettingsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-19.
//

import SwiftUI

struct LocationSettingsView: View {
    @ObservedObject var dbHelper = FireDBHelper.getInstance()
    @State private var radius: Double = 2.0

    var body: some View {
        Form {
            if let user = dbHelper.currentUser {
                Toggle("Enable Location Filtering", isOn: Binding(
                    get: { user.locationConsent },
                    set: { newValue in
                        Task {
                            try? await dbHelper.updateUserLocationPreference(
                                consent: newValue,
                                latitude: user.latitude,
                                longitude: user.longitude,
                                radius: radius
                            )
                        }
                    }
                ))
                
                if user.locationConsent {
                    HStack {
                        Text("Radius (km)")
                        Slider(value: $radius, in: 1...10, step: 0.5)
                        Text("\(radius, specifier: "%.1f") km")
                    }
                }
            }
        }
        .onAppear {
            radius = dbHelper.currentUser?.preferredRadius ?? 2.0
        }
        .navigationTitle("Location Settings")
    }
}
