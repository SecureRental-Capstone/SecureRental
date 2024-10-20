//
//  SignInView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

import SwiftUI

struct SignInView: View {
    
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
                
//                                            self.login()
                self.rootView = .main

            }){
                Text("Login")
                    .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Button(action: {
                //set rootView to .signUp to navigate to SignUpView
                self.rootView = .signUp
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
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
//    SignInView()
//}
