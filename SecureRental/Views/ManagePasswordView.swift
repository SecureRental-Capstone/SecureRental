
import SwiftUI

struct ManagePasswordView: View {
    
    @State private var showReset = false
    @State private var showTwoFactor = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                   
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




//Mock Functionality
struct TwoFactorAuthPage: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var code: String = ""
    @State private var message: String = ""
    @State private var isError: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            // Close Button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
                    .padding()
            }
            
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
        
                Text("Two-Factor Authentication")
                    .font(.largeTitle)
                    .bold()
                
               
                Text("Enter the 6-digit verification code to continue.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
          
                TextField("Verification Code", text: $code)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
      
                Button(action: mockVerifyCode) {
                    Text("Verify Code")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryPurple)
                        .cornerRadius(10)
                }
                .opacity(code.isEmpty ? 0.5 : 1)
                .disabled(code.isEmpty)
                
        
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(isError ? .red : .green)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
   
    func mockVerifyCode() {
        guard !code.isEmpty else {
            message = "Please enter the verification code."
            isError = true
            return
        }
        
        if code == "123456" { 
            message = "Code verified successfully!"
            isError = false
        } else {
            message = "Invalid verification code."
            isError = true
        }
    }
}
