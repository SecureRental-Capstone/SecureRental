//
//  SignUpView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

import SwiftUI

struct SignUpView: View {
    
    @Binding var rootView : RootView

    @State private var email : String = ""
    @State private var password : String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    var body: some View {
        VStack{
            
            Spacer()
            
            Text("Secure Rental")
                .font(.title)
                        
            TextField("username", text: $email)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
                SecureField("password", text: $password)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            
                Button(action: {
                    
//                    self.createAccount()
                    self.rootView = .authentication
                }){
                    Text("Create Account")
                        .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
                        .frame(maxWidth: .infinity)
                    
                }
                .buttonStyle(.borderedProminent)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top, 24)
                .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Error"),
                                    message: Text(alertMessage),
                                    dismissButton: .default(Text("OK")) {
                                        showAlert = false
                                    }
                                )
                            }

            Button(action: {
                //set rootView to .login to navigate to login page
                self.rootView = .login
            }) {
                Text("Already have an account? Log In")
                    .foregroundColor(.blue)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                showAlert = false
                }
            )
        }
    }//body
}

//#Preview {
//    SignUpView()
//}
