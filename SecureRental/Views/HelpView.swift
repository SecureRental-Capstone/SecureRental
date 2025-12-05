//
//  HelpView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-11-22.
//


import SwiftUI

struct HelpView: View {
    @State private var showFAQ = false
    @State private var showContactSupport = false
    @State private var showTroubleshooting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
              
                VStack(spacing: 8) {
                    Text("Help & Support")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Find answers to common questions or contact our team for more support.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
              
                
            
                VStack(spacing: 16) {
                    
                    HelpCard(
                        title: "Frequently Asked Questions",
                        subtitle: "View answers to common app questions.",
                        systemImage: "questionmark.circle.fill",
                        tint: .primaryPurple
                    ) {
                        showFAQ = true
                    }
                    Divider()

                    Divider()
                    HelpCard(
                        title: "Contact Support",
                        subtitle: "Reach out to our team for personal assistance.",
                        systemImage: "envelope.fill",
                        tint: .green
                    ) {
                        showContactSupport = true
                    }
                }
                .padding(.horizontal)
                
                
             
                VStack(alignment: .leading, spacing: 6) {
                    Text("App Information")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Version: 1.0.0")
                        Text("Updated: December 2025")
                        Text("SecureRental © 2025")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Help")
        .sheet(isPresented: $showFAQ) {
            FAQView()
        }
        .sheet(isPresented: $showTroubleshooting) {
            TroubleshootView()
        }
        .sheet(isPresented: $showContactSupport) {
            ContactSupportView()
        }
    }
}



struct HelpCard: View {
    var title: String
    var subtitle: String
    var systemImage: String
    var tint: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(tint)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
    }
}



struct FAQView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
                    DisclosureGroup("How do I edit my listings?") {
                        Text("Go to “Profile”, and click My Listings, tap the listing you want to edit, and then tap the Edit button in the top-right corner.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                    
                    DisclosureGroup("How do I update my profile?") {
                        Text("Open the Profile tab, tap “Edit Profile Details”, update your details, and then tap Save.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                    
                    DisclosureGroup("How do I reset my password?") {
                        Text("On the Sign In screen, tap “Forgot Password?”, enter your email, and follow the link sent to your inbox. or Go to Profile Tab and click forgot password ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                    DisclosureGroup("How do I create a new Listing?") {
                        Text("In the order to create a new listing, you have to verify your Identity on the Profile Page. Once, the identity is verified, Create Listing button will be automatically enabled ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                    DisclosureGroup("How do I change the currency?") {
                        Text("In the HomePage, on the top right, there is icon to change the currency of the displayed listing prices. ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("FAQs")
        }
    }
}


struct TroubleshootView: View {
    var body: some View {
        NavigationView {
            Text("Troubleshooting Tips Coming Soon")
                .padding()
                .navigationTitle("Troubleshooting")
        }
    }
}

struct ContactSupportView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Contact Support")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Email us at:")
                Text("securerentalcapston@gmail.com")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Support")
        }
    }
}
