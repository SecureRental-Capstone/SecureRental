//
//  CurrencyPickerButton.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-18.
//
import SwiftUI

struct CurrencyPickerButton: View {
    // Requires CurrencyOption to be defined in Models.swift
    @Binding var selected: CurrencyOption
    var options: [CurrencyOption]

    var body: some View {
        Menu {
            ForEach(options) { currency in
                Button {
                    selected = currency
                } label: {
                    HStack(spacing: 10) {
                        Text("\(currency.flag) \(currency.code) (\(currency.symbol))")
                        
                        if currency == selected {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selected.flag)
                    .font(.system(size: 20))
                
                Text(selected.code)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3))
            )
        }
    }
}
