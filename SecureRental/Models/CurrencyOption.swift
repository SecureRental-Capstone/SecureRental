//
//  CurrencyOption.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-18.
//

import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let id = UUID()
    let code: String       
    let symbol: String
    let flag: String
    let rate: Double
}

struct RateResponse: Codable {
    let rates: [String: Double]
}
