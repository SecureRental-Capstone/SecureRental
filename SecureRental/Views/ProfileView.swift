//
//  ProfileView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2024-11-06.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var user: User
    
    var body: some View {
        VStack {
                // Profile Header with image and name
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.leading, 20)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 10)
                Spacer()
            }
            .padding(.top, 40)
            
            Divider() // Add a line separator
            
                // Profile Information Section
            VStack(alignment: .leading, spacing: 15) {
                Text("About Me")
                    .font(.headline)
                    .padding(.top, 20)
                
                Text(user.bio!)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Divider() // Line separator
                
                    // Address
                Text("Address")
                    .font(.headline)
                
                Text(user.address!)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Divider()
                
                    // Phone Number
                Text("Phone Number")
                    .font(.headline)
                
                Text(user.phoneNumber!)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
                // Edit Profile Button
            Button(action: {
                    // Handle Edit Profile action
            }) {
                Text("Edit Profile")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
                // Log Out Button
            Button(action: {
                    // Handle Log Out action
            }) {
                Text("Log Out")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top) // Ignore top safe area to push content to the top
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.sampleUser)
            .previewDevice("iPhone 14")
    }
}
