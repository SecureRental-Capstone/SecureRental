//
//  CurrencyViewModel.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-18.
//

import Foundation

@MainActor
class CurrencyViewModel: ObservableObject {
    @Published var selectedCurrency: CurrencyOption
    @Published var currencies: [CurrencyOption] = []

    let basePrice: Double = 100.0  // Example base price in USD

    init() {
        // Initial placeholder value before async fetch finishes
        selectedCurrency = CurrencyOption(code: "CAD", symbol: "$", flag: "🇨🇦", rate: 1.0)

        Task {
            await fetchRates()
        }
    }

    func fetchRates() async {
        guard let url = URL(string: "https://open.er-api.com/v6/latest/CAD") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(RateResponse.self, from: data)

            let mapping: [(String, String, String)] = [
                ("USD", "$", "🇺🇸"),
                ("CAD", "C$", "🇨🇦"),
                ("EUR", "€", "🇪🇺"),
                ("GBP", "£", "🇬🇧"),
                ("INR", "₹", "🇮🇳"), // Added Indian Rupee
                ("PKR", "₨ ", "🇵🇰") // Added Pakistani Rupee
            ]

            currencies = mapping.compactMap { (code, symbol, flag) in
                if let rate = decoded.rates[code] {
                    return CurrencyOption(code: code, symbol: symbol, flag: flag, rate: rate)
                }
                return nil
            }

            // Update selectedCurrency to real fetched USD model
            if let usd = currencies.first(where: { $0.code == "USD" }) {
                selectedCurrency = usd
            }

        } catch {
            print("Failed to fetch rates:", error)
        }
    }

//    func convertedPrice() -> String {
//        let value = basePrice * selectedCurrency.rate
//        return String(format: "%@%.2f", selectedCurrency.symbol, value)
//    }
    func convertedPrice(basePriceString: String) -> String {
        // Ensure the price string can be converted to a Double.
        guard let basePriceInUSD = Double(basePriceString) else {
            return "N/A"
        }
        
        // Find the rate for the selected currency. Use 1.0 if somehow missing.
        let rate = selectedCurrency.rate
        
        // Calculate the converted price
        let convertedValue = basePriceInUSD * rate
        
        // Format the output string
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency.code
        formatter.currencySymbol = selectedCurrency.symbol
        formatter.maximumFractionDigits = 0 // Show whole numbers for rent
        
        return formatter.string(from: NSNumber(value: convertedValue)) ?? "\(selectedCurrency.symbol)\(Int(convertedValue))"
    }
}
