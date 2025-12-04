
import SwiftUI
import Persona2


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
//    private let personaDelegate = PersonaHandler()

    var body: some View {
   
        ZStack {
            Color.lightGrayBackground.ignoresSafeArea()
            
      
            VStack(spacing: 0) {
                
              
                VStack(spacing: 4) {
                    Text("SecureRental")
                        .font(.title) // Increased size for prominence
                        .fontWeight(.bold) // Increased weight
                        .foregroundColor(.primaryPurple)
                }
                .padding(.bottom, 24) // Controlled gap between title and card
            
           
                VStack(spacing: 0) {
                    
                  
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
                                SecureField("••••••••", text: $confirmPassword)
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
                .padding(.top, 32)
                .frame(maxWidth: 400)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 20)
          
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
    

}
