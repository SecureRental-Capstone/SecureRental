//
//  CurrencyOption.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-18.
//

import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let id = UUID()
    let code: String       // e.g. "USD"
    let symbol: String     // e.g. "$"
    let flag: String       // e.g. "🇺🇸"
    let rate: Double       // exchange rate relative to base
}

struct RateResponse: Codable {
    let rates: [String: Double]
}
