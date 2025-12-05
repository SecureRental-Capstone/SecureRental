//
//  TermsofUseView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-09-30.
//


import SwiftUI

struct TermsofUseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
//                Text("Terms of Use")
//                    .font(.largeTitle)
//                    .bold()
                
                Text("""
Welcome to SecureRental. By using our app, you agree to comply with these Terms of Use. Please read them carefully.

1. Acceptance of Terms
By accessing or using SecureRental, you agree to be bound by these Terms of Use.

2. User Responsibilities
- Provide accurate information when signing up.
- Do not post illegal or harmful content.

3. Account & Privacy
You are responsible for maintaining the confidentiality of your account credentials. See our Privacy Policy for more details.

4. Content
All content in the app is owned by SecureRental or our licensors. You may not copy, reproduce, or distribute any part of the app without permission.

5. Limitation of Liability
SecureRental is provided “as is.” We are not liable for any damages arising from the use of the app.

""")
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Terms of Use")
    }
}

