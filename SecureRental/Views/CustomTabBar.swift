//
//  CustomTabBar.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-18.
//
import SwiftUI

/// A custom view for the bottom persistent tab bar.
struct CustomTabBar: View {
    @Binding var selectedTab: String
    
    struct TabItem: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
    }
    
    let tabs: [TabItem] = [
        .init(name: "Search", icon: "magnifyingglass"),
        .init(name: "Favorites", icon: "heart.fill"),
        .init(name: "Messages", icon: "message.fill"),
        .init(name: "Profile", icon: "person.fill")
    ]
    
    var body: some View {
        HStack {
            ForEach(tabs) { item in
                Button {
                    selectedTab = item.name
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 22))
                        Text(item.name)
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == item.name ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
}
