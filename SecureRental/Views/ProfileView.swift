import SwiftUI

struct ProfileView: View {
    @ObservedObject var user: User
    @Binding var rootView: RootView
    @EnvironmentObject private var authenticationService: AuthenticationService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
            
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.leading, 20)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(user.name ?? "User Name")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", user.rating ?? 4.0))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                .background(Color.gray.opacity(0.1))
                
       
                List {
                        // Profile Details
                    Section(header: Text("Profile").font(.headline)) {
                        NavigationLink(destination: ProfileDetailsView(user: user)) {
                            Label("Profile Details", systemImage: "person.fill")
                        }
                    }
                    
                        // Account Settings
                    Section(header: Text("Account Settings").font(.headline)) {
                        NavigationLink(destination: ManageAccountView()) {
                            Label("Manage Account", systemImage: "gearshape.fill")
                        }
                        NavigationLink(destination: NotificationPreferencesView()) {
                            Label("Notification Preferences", systemImage: "bell.fill")
                        }
                    }
                    
                        // General Information
                    Section(header: Text("General Information").font(.headline)) {
                        NavigationLink(destination: TermsOfUseView()) {
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
                    
                    Section {
                        Button(action: {
                                // Perform the sign out asynchronously
                            Task {
                                await authenticationService.signOut()
                                    // After sign out, navigate to the login screen
                                self.rootView = .login
                            }
                        }) {
                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }

                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle("My Profile", displayMode: .inline)
            .background(Color.white)
        }
    }
}

    // Placeholder Views for Navigation Links
struct ProfileDetailsView: View {
    var user: User
    var body: some View {
        Text("Profile Details for \(user.name ?? "User")")
    }
}

struct ManageAccountView: View {
    var body: some View { Text("Manage Account") }
}

struct NotificationPreferencesView: View {
    var body: some View { Text("Notification Preferences") }
}

struct TermsOfUseView: View {
    var body: some View { Text("Terms of Use") }
}

struct PrivacyPolicyView: View {
    var body: some View { Text("Privacy Policy") }
}

struct HelpView: View {
    var body: some View { Text("Help") }
}

struct AppThemeSettingsView: View {
    var body: some View { Text("App Theme Settings") }
}
