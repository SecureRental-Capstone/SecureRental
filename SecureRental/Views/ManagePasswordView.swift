
import SwiftUI

struct ManagePasswordView: View {
    
    @State private var showReset = false
    @State private var showTwoFactor = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                    // MARK: Header
                VStack(spacing: 8) {
                    Text("Security Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Manage your password and enable additional security options.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                
                    // MARK: Options
                VStack(spacing: 16) {
                    
                        // Reset Password
                    SecurityOptionCard(
                        title: "Reset Password",
                        subtitle: "Change your account password securely.",
                        systemImage: "key.fill",
                        tint: .blue
                    ) {
                        showReset = true
                    }
                    
                        // Two-Factor Authentication
                    SecurityOptionCard(
                        title: "Two-Factor Authentication",
                        subtitle: "Add an extra layer of protection to your account.",
                        systemImage: "shield.lefthalf.filled",
                        tint: .green
                    ) {
                        showTwoFactor = true
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Password & Security")
        .sheet(isPresented: $showReset) {
            ResetPasswordView()
        }
        .sheet(isPresented: $showTwoFactor) {
            TwoFactorAuthPage()
        }
    }
}



    // MARK: – Reusable Card Component
struct SecurityOptionCard: View {
    
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
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
    }
}




struct TwoFactorAuthPage: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Two-Factor Authentication")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add extra security to your account with two-factor authentication.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Two-Factor Auth")
            .padding()
        }
    }
}
