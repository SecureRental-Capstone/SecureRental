

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
    private let personaDelegate = PersonaHandler()
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Create an Account")
                .font(.title)
            TextField("Name", text: $name)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.words)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            TextField("Email", text: $email)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            SecureField("Password", text: $password)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            SecureField("Confirm Password", text: $confirmPassword)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            Button(action: {
                Task {
                    await signUp()
                }
            }) {
                Text("Sign Up")
                    .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Button(action: {
                self.rootView = .login
            }) {
                Text("Already have an account? Log In")
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "An unexpected error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
//    private func signUp() async {
//        // Insert user
//        let newUser = AppUser(username: email, email: email, name: "NA")
//        await dbHelper.insertUser(user: newUser)
//        
//        // Fetch user by UID
//        if let user = await dbHelper.getUser(byUID: newUser.id) {
//            print(user.name)
//        }
//    }
    
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
            startPersonaFlow()
            try await Task.sleep(nanoseconds: 9_000_000_000)
            rootView = .main
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
    
    func startPersonaFlow() {
        isLoading = true

        createPersonaInquiry(firstName: "Jane", lastName: "Doe", birthdate: "1994-04-12") { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let inquiryId):
                    print("Inquiry ID: \(inquiryId)")

                    //launch the Persona SDK flow using the delegate handler
                    if let topVC = UIApplication.shared.topViewController() {
                        Persona2.Inquiry
                            .from(inquiryId: inquiryId, delegate: personaDelegate)  //pass delegate
                            .build()
                            .start(from: topVC)
                    }

                case .failure(let error):
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
}
