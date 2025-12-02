//import SwiftUI
//
//struct ProfileView: View {
//    @Binding var rootView: RootView
//    @EnvironmentObject var dbHelper: FireDBHelper
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                
//                if let user = dbHelper.currentUser {
//                    // ⬇️ header
//                    HStack {
//                        // PROFILE IMAGE (from Cloudinary if present)
//                        if let urlString = user.profilePictureURL,
//                           !urlString.isEmpty,
//                           let url = URL(string: urlString) {
//                            AsyncImage(url: url) { phase in
//                                switch phase {
//                                case .empty:
//                                    ProgressView()
//                                        .frame(width: 80, height: 80)
//                                case .success(let image):
//                                    image
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 80, height: 80)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
//                                case .failure:
//                                    Image(systemName: "person.circle.fill")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 80, height: 80)
//                                        .foregroundColor(.blue)
//                                @unknown default:
//                                    EmptyView()
//                                }
//                            }
//                            .padding(.leading, 20)
//                        } else {
//                            // fallback placeholder
//                            Image(systemName: "person.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 80, height: 80)
//                                .foregroundColor(.blue)
//                                .padding(.leading, 20)
//                        }
//                        
//                        VStack(alignment: .leading, spacing: 5) {
//                            Text(user.name ?? "User Name")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                            
//                            // rating stars (your existing logic)
//                            HStack(spacing: 2) {
//                                let rating = user.rating ?? 4.0
//                                let fullStars = Int(rating)
//                                let hasHalfStar = (rating - Double(fullStars)) >= 0.25 && (rating - Double(fullStars)) < 0.75
//                                let emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0)
//                                
//                                ForEach(0..<fullStars, id: \.self) { _ in
//                                    Image(systemName: "star.fill")
//                                        .foregroundColor(.yellow)
//                                }
//                                if hasHalfStar {
//                                    Image(systemName: "star.leadinghalf.fill")
//                                        .foregroundColor(.yellow)
//                                }
//                                ForEach(0..<emptyStars, id: \.self) { _ in
//                                    Image(systemName: "star")
//                                        .foregroundColor(.yellow)
//                                }
//                                
//                                Text(String(format: "%.1f", rating))
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        
//                        Spacer()
//                    }
//                    .padding(.top, 40)
//                    .padding(.bottom, 20)
//                    .background(Color.gray.opacity(0.1))
//                    
//                    // ⬇️ rest of your list stays the same
//                    List {
//                        Section(header: Text("Profile").font(.headline)) {
//                            NavigationLink(destination: ProfileDetailsView(user: user).environmentObject(dbHelper)) {
//                                Label("Edit Profile Details", systemImage: "person.fill")
//                            }
//                        }
//                        
//                        Section(header: Text("Account Settings").font(.headline)) {
//                            NavigationLink(destination: ManageAccountView()) {
//                                Label("Manage Account", systemImage: "gearshape.fill")
//                            }
//                            NavigationLink(destination: NotificationPreferencesView()) {
//                                Label("Notification Preferences", systemImage: "bell.fill")
//                            }
//                        }
//                        
//                        Section(header: Text("General Information").font(.headline)) {
//                            NavigationLink(destination: TermsofUseView()) {
//                                Label("Terms of Use", systemImage: "doc.text")
//                            }
//                            NavigationLink(destination: PrivacyPolicyView()) {
//                                Label("Privacy Policy", systemImage: "lock.fill")
//                            }
//                            NavigationLink(destination: HelpView()) {
//                                Label("Help", systemImage: "questionmark.circle.fill")
//                            }
//                        }
//                        
//                        Section(header: Text("Display Settings").font(.headline)) {
//                            NavigationLink(destination: AppThemeSettingsView()) {
//                                Label("App Theme", systemImage: "paintpalette.fill")
//                            }
//                        }
//                        
//                        Section(header: Text("My Listings").font(.headline)) {
//                            NavigationLink(destination: MyListingsView()) {
//                                Label("My Listings", systemImage: "house.fill")
//                            }
//                        }
//                        
//                        Section {
//                            Button(action: {
//                                Task {
//                                    // your sign-out
//                                    self.rootView = .login
//                                }
//                            }) {
//                                Text("Log Out")
//                                    .font(.headline)
//                                    .foregroundColor(.red)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                            }
//                        }
//                    }
//                    .listStyle(GroupedListStyle())
//                }
//            }
//            .navigationBarTitle("My Profile", displayMode: .inline)
//            .background(Color.white)
//        }
//    }
//}
//
//struct ManageAccountView: View {
//    var body: some View { Text("Manage Account") }
//}
//
//struct NotificationPreferencesView: View {
//    var body: some View { Text("Notification Preferences") }
//}
//
////struct TermsOfUseView: View {
////    var body: some View { Text("Terms of Use") }
////}
//
//
//
//struct HelpView: View {
//    var body: some View { Text("Help") }
//}

//struct AppThemeSettingsView: View {
//    var body: some View { Text("App Theme Settings") }
//}
    ///
    ///
    ///
    ///
    ///


import SwiftUI
import Persona2

struct ProfileView: View {
    @Binding var rootView: RootView
    @EnvironmentObject var dbHelper: FireDBHelper
    @EnvironmentObject var currencyManager: CurrencyViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                if let user = dbHelper.currentUser {
                    
                        // MARK: - HEADER CARD
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            
                                // MARK: – PROFILE IMAGE
                            if let urlString = user.profilePictureURL,
                               !urlString.isEmpty,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 80, height: 80)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    case .failure:
                                        Image(systemName: "person.crop.circle.badge.exclam")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(.blue)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.blue)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            
                            
                                // MARK: – NAME + RATING
                            VStack(alignment: .leading, spacing: 6) {
                                Text(user.name ?? "User Name")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 4) {
                                    let rating = user.rating ?? 4.0
                                    let full = Int(rating)
                                    let hasHalf = rating - Double(full) >= 0.25 && rating - Double(full) < 0.75
                                    let empty = 5 - full - (hasHalf ? 1 : 0)
                                    
                                    ForEach(0..<full, id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    if hasHalf {
                                        Image(systemName: "star.leadinghalf.fill")
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    ForEach(0..<empty, id: \.self) { _ in
                                        Image(systemName: "star")
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    Text(String(format: "%.1f", rating))
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    if let user = dbHelper.currentUser, user.isVerified == false {
                        VerifyIdentityCard(rootView: self.$rootView)
                             .environmentObject(dbHelper)
                             .padding(.top, 10)
                     }
                    
                        // MARK: - LIST SECTIONS
                    List {
                            // Profile Section
                        Section(header: Text("Profile").font(.headline)) {
                            NavigationLink(destination: ProfileDetailsView(user: user).environmentObject(dbHelper)) {
                                Label("Edit Profile Details", systemImage: "person.fill")
                            }
                        }
                        
                            // Account Settings
                        Section(header: Text("Account Settings").font(.headline)) {
                            NavigationLink(destination: ManagePasswordView()) {
                                Label("Password and Security", systemImage: "lock.shield")
                            }
                            NavigationLink(destination: ManageAccountView()) {
                                Label("Manage Account", systemImage: "gearshape.fill")
                            }
                            
                            NavigationLink(destination: NotificationPreferencesView()) {
                                Label("Notification Preferences", systemImage: "bell.badge.fill")
                            }
                        }
                        
                            // General Info
                        Section(header: Text("General Information").font(.headline)) {
                            NavigationLink(destination: TermsofUseView()) {
                                Label("Terms of Use", systemImage: "doc.text")
                            }
                            
                            NavigationLink(destination: PrivacyPolicyView()) {
                                Label("Privacy Policy", systemImage: "lock.fill")
                            }
                            
                            NavigationLink(destination: HelpView()) {
                                Label("Help", systemImage: "questionmark.circle.fill")
                            }
                        }
                        
                            // Display Settings
                        Section(header: Text("Display Settings").font(.headline)) {
                            NavigationLink(destination: AppThemeSettingsView()) {
                                Label("App Theme", systemImage: "paintpalette.fill")
                            }
                        }
                        
                            // My Listings
                        Section(header: Text("My Listings").font(.headline)) {
                            NavigationLink(destination: MyListingsView().environmentObject(dbHelper).environmentObject(currencyManager)) {
                                Label("My Listings", systemImage: "house.fill")
                            }
                        }
//                        Divider()
//                            .padding(.top, 20)
                        
                            // Logout
                        Section {
                            Button(role: .destructive) {
                                Task {
                                    self.rootView = .login
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Log Out")
                                        .font(.headline)
                                    Spacer()
                                }
                            }
//                            .padding()
//                            .background(
//                                .ultraThinMaterial
//                                    .opacity(0.5)
//                            ) // ⭐ stronger blur
//                            .cornerRadius(14)
//                          .padding(.horizontal)
//
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitle("My Profile", displayMode: .inline)
        }
    }

}

struct ManageAccountView: View { var body: some View { Text("Manage Account") } }
struct NotificationPreferencesView: View { var body: some View { Text("Notification Preferences") } }

