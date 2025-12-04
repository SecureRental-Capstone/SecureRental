
import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                
                    // Title
                Text("Privacy Policy")
                    .font(.largeTitle.bold())
                    .padding(.top, 10)
                
                    // Subtitle
                Text("Last updated: November 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider().padding(.vertical, 5)
                
                Group {
                    Text("Your Privacy Matters")
                        .font(.headline)
                    Text("""
                    At SecureRental, we are committed to protecting your personal information and ensuring transparency about how your data is used. This policy explains what data we collect, how we use it, and the rights you have.
                    """)
                }
                
                Group {
                    Text("Information We Collect")
                        .font(.headline)
                    Text("""
                    • Profile details (name, email, phone number)
                    • Listing information you upload
                    • Search history and preferences
                    • Location data (only when you approve it)
                    """)
                }
                
                Group {
                    Text("How We Use Your Information")
                        .font(.headline)
                    Text("""
                    • To provide accurate listing matches
                    • To verify landlords and renters
                    • To enable messaging and support
                    • To improve app experience and security
                    """)
                }
                
                Group {
                    Text("Data Protection")
                        .font(.headline)
                    Text("""
                    Your data is encrypted and stored securely. We do not sell your personal information to third parties. Only trusted service partners may access necessary data to operate core app functions (e.g., authentication).
                    """)
                }
                
                Group {
                    Text("Your Rights")
                        .font(.headline)
                    Text("""
                    You can request to:
                    • Delete your account  
                    • Update your information  
                    • Export your data  
                    • Disable certain permissions  
                    """)
                }
                
                Group {
                    Text("Contact Us")
                        .font(.headline)
                    Text("""
                    If you have questions about this policy or need help, please contact us at:
                    securerentalcapstone@gmail.com
                    """)
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

