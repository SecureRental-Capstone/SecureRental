//import SwiftUI
//import Persona2
//
//struct SignUpView: View {
//    @Binding var rootView: RootView
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var errorMessage: String?
//    @State private var name: String = ""
//    @State private var showAlert: Bool = false
//    @EnvironmentObject var dbHelper : FireDBHelper
//
//    @State private var isLoading = false
//    @State private var showError = false
//    private let personaDelegate = PersonaHandler()
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            
//            Text("Create an Account")
//                .font(.title)
//            TextField("Name", text: $name)
//                .autocorrectionDisabled(true)
//                .textInputAutocapitalization(.words)
//                .padding()
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
//            TextField("Email", text: $email)
//                .autocorrectionDisabled(true)
//                .textInputAutocapitalization(.never)
//                .padding()
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
//            
//            SecureField("Password", text: $password)
//                .autocorrectionDisabled(true)
//                .textInputAutocapitalization(.never)
//                .padding()
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
//            
//            SecureField("Confirm Password", text: $confirmPassword)
//                .autocorrectionDisabled(true)
//                .textInputAutocapitalization(.never)
//                .padding()
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
//            
//            Button(action: {
//                Task {
//                    await signUp()
//                }
//            }) {
//                Text("Sign Up")
//                    .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.borderedProminent)
//            .background(Color.blue)
//            .cornerRadius(10)
//            .padding(.top, 24)
//            
//            Button(action: {
//                self.rootView = .login
//            }) {
//                Text("Already have an account? Log In")
//                    .foregroundColor(.blue)
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .alert(isPresented: $showAlert) {
//            Alert(
//                title: Text("Error"),
//                message: Text(errorMessage ?? "An unexpected error occurred."),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//    
//    private func signUp() async {
//        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
//            errorMessage = "Please fill in all fields."
//            showAlert = true
//            return
//        }
//        guard password == confirmPassword else {
//            errorMessage = "Passwords do not match."
//            showAlert = true
//            return
//        }
//        do {
//            try await dbHelper.signUp(email: email, password: password, name: name)
//            startPersonaFlow()
//            try await Task.sleep(nanoseconds: 9_000_000_000)
//            rootView = .main
//        } catch {
//            errorMessage = error.localizedDescription
//            showAlert = true
//        }
//    }
//    
//    func startPersonaFlow() {
//        isLoading = true
//
//        createPersonaInquiry(firstName: "Jane", lastName: "Doe", birthdate: "1994-04-12") { result in
//            DispatchQueue.main.async {
//                isLoading = false
//
//                switch result {
//                case .success(let inquiryId):
//                    print("Inquiry ID:", inquiryId)
//
//                    if let topVC = UIApplication.shared.topViewController() {
//
//                        let wrapper = PersonaWrapperVC()
//                        wrapper.modalPresentationStyle = .fullScreen  // Prevent UIKit auto-dismiss
//                        wrapper.modalTransitionStyle = .coverVertical // Optional
//
//                        topVC.present(wrapper, animated: true) {
//                            Persona2.Inquiry
//                                .from(inquiryId: inquiryId, delegate: personaDelegate)
//                                .build()
//                                .start(from: wrapper)
//                        }
//                    }
//
//                case .failure(let error):
//                    showError = true
//                    errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//
//    
//    
//}

import SwiftUI
import Persona2

// MARK: - Main View
struct SignUpView: View {
    
    @Binding var rootView: RootView
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var name: String = ""
    @State private var showAlert: Bool = false
    @EnvironmentObject var dbHelper : FireDBHelper

    @State private var isLoading = false
    @State private var showError = false
    private let personaDelegate = PersonaHandler()

    var body: some View {
        // 1. Background Layer
        ZStack {
            Color.lightGrayBackground.ignoresSafeArea()
            
            // FIX: Single main VStack to hold all vertical elements in order
            VStack(spacing: 0) {
                
                // --- Title (SecureRental) ---
                VStack(spacing: 4) {
                    Text("SecureRental")
                        .font(.title) // Increased size for prominence
                        .fontWeight(.bold) // Increased weight
                        .foregroundColor(.primaryPurple)
                }
                .padding(.bottom, 24) // Controlled gap between title and card
            
                // 2. Main Card Container
                VStack(spacing: 0) {
                    
                    // Form Fields Section Container
                    VStack(alignment: .leading, spacing: 24) {
                        // Full Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.gray)
                                TextField("John Doe", text: $name)
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                            }
                            .modifier(CustomTextFieldStyle())
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                TextField("", text: $email, prompt: Text(verbatim: "account@email.com"))
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .modifier(CustomTextFieldStyle())
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                SecureField("••••••••", text: $password)
                                    .autocorrectionDisabled(true)
                                    .textInputAutocapitalization(.never)
                            }
                            .modifier(CustomTextFieldStyle())
                        }
                        
                        // Re-type Password Field (FIXED binding)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Re-type Password")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                SecureField("••••••••", text: $confirmPassword) // FIX: Correctly bound to $confirmPassword
                            }
                            .modifier(CustomTextFieldStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    
                    // Create Account Button
                    Button(action: {
                        Task {
                            await signUp()
                        }
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.primaryPurple)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    
                    // Or Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    
                    // Already have an account? Sign In
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.body)
                            .foregroundColor(.gray)
                        Button(action: {
                            self.rootView = .login
                        }) {
                            Text("Sign in")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryPurple)
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding(.top, 32) // Top padding inside the card to push content down
                .frame(maxWidth: 400) // Constraints the card width
                .background(Color.white)
                .cornerRadius(20) // Rounded card corners
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5) // Subtle card shadow
            }
            .padding(.horizontal, 20) // General horizontal padding for the entire page content
            // The alert needs to be attached to a view inside the ZStack
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "An unknown error occurred."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func signUp() async {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            errorMessage = "Please fill in all fields."
            showAlert = true
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showAlert = true
            return
        }
        do {
            try await dbHelper.signUp(email: email, password: password, name: name)
            rootView = .verification
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
    
//    func startPersonaFlow() {
//        isLoading = true
//
//        createPersonaInquiry(firstName: "Jane", lastName: "Doe", birthdate: "1994-04-12") { result in
//            DispatchQueue.main.async {
//                isLoading = false
//
//                switch result {
//                case .success(let inquiryId):
//                    print("Inquiry ID:", inquiryId)
//
//                    if let topVC = UIApplication.shared.topViewController() {
//
//                        let wrapper = PersonaWrapperVC()
//                        wrapper.modalPresentationStyle = .fullScreen
//                        wrapper.modalTransitionStyle = .coverVertical
//
//                        topVC.present(wrapper, animated: true) {
//                            Persona2.Inquiry
//                                .from(inquiryId: inquiryId, delegate: personaDelegate)
//                                .build()
//                                .start(from: wrapper)
//                        }
//                    }
//
//                case .failure(let error):
//                    showError = true
//                    errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
}
