//
//  ProfileDetailsView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-09-29.
//

import SwiftUI
import PhotosUI

struct ProfileDetailsView: View {
    var user: AppUser
    @EnvironmentObject var dbHelper: FireDBHelper
    @State private var name: String
    @State private var username: String
    @State private var profilePicture: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(user: AppUser) {
        self.user = user
        _name = State(initialValue: user.name)
        _username = State(initialValue: user.username)
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                    // Editable Profile Picture
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let profilePicture = profilePicture {
                            // Show locally selected image
                        Image(uiImage: profilePicture)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    } else if let profileURLString = user.profilePictureURL,
                              !profileURLString.isEmpty,
                              let url = URL(string: profileURLString) {
                            // Show remote image from URL
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 120, height: 120)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            case .failure:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                            // Placeholder
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(Text("Add Photo").font(.caption))
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            profilePicture = uiImage
                        }
                    }
                }

                
                    // Editable Form Fields
                Form {
                    Section(header: Text("Profile Information")) {
                        HStack {
                            Text("Name")
                                .foregroundColor(.gray)
                            Spacer()
                            TextField("", text: $name)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Username")
                                .foregroundColor(.gray)
                            Spacer()
                            TextField("", text: $username)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Email")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 200) // optional, adjust to fit
                
                    // Save Button
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle("Edit Profile")
        .alert("Update Profile", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveChanges() {
        
        var updatedUser = user
        updatedUser.name = name
        updatedUser.username = username
        
        Task {
            await dbHelper.updateUser(user: updatedUser)
            alertMessage = "Profile updated successfully!"
            showAlert = true
        }
    }
}

