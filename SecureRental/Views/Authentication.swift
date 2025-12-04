//
//  Authentication.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-11-06.
//

import SwiftUI

struct Authentication: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var selectedDocumentType: String = ""
    @State private var isDocumentUploaded: Bool = false
    @Binding var rootView : RootView

 
    let documentTypes = ["Drivers License", "Passport", "Health Card"]
    
    var body: some View {
                
        VStack(spacing: 20) {
            // Title
            Text("Identity Verification")
                .font(.largeTitle)
                .bold()
                 
            Spacer()

            // First Name
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            //Spacer()
            
            // Last Name
            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
           // Spacer()
            
            // First Name
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            //Spacer()

            // Document Type Picker with placeholder
            VStack {
                Picker("Type of ID", selection: $selectedDocumentType) {
                    Text("Select ID Type").tag("") // Placeholder
                    ForEach(documentTypes, id: \.self) { document in
                        Text(document).tag(document)
                    }
                }
                .pickerStyle(MenuPickerStyle()) //
                .frame(width: 305, height: 35)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.gray
                    .opacity(0.2), lineWidth: 1))
                .padding(.horizontal)
            }
            
         
            Button(action: {
                // Logic for uploading
                isDocumentUploaded.toggle()
            }) {
                HStack {
                    Image(systemName: isDocumentUploaded ? "checkmark.circle.fill" : "icloud.and.arrow.up.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text(isDocumentUploaded ? "Document Uploaded" : "Click to Upload ID")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 150)
                .background(Color.gray)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            Spacer()

            
            // Continue Button
            Button(action: {
                //set to main view
                self.rootView = .main
                print("Continue button pressed")
            }) {
                Text("Continue")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}
