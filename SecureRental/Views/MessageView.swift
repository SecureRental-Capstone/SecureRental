////
////  MessageView.swift
////  SecureRental
////
////  Created by Shehnazdeep Kaur on 2024-10-21.
////
//

import SwiftUI

    // Models
struct Message: Identifiable {
    let id = UUID()
    let content: String
    let sender: String
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let messages: [Message]
}

    // Sample Data
let sampleContacts: [Contact] = [
    Contact(name: "Alice", messages: [
        Message(content: "Hey there!", sender: "Alice"),
        Message(content: "How's it going?", sender: "Alice")
    ]),
    Contact(name: "Bob", messages: [
        Message(content: "Hello!", sender: "Bob"),
        Message(content: "Let's catch up soon.", sender: "Bob")
    ])
]

    // Views
struct MessageView: View {
    @Environment(\.dismiss) private var dismiss
    let contacts: [Contact] = sampleContacts
    
    var body: some View {
        NavigationView {
            List(contacts) { contact in
                NavigationLink(destination: MessageListView(contact: contact)) {
                    Text(contact.name)
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MessageListView: View {
    let contact: Contact
    
    var body: some View {
        List(contact.messages) { message in
            NavigationLink(destination: MessageDetailView(message: message)) {
                Text(message.content)
            }
        }
        .navigationTitle(contact.name)
    }
}

struct MessageDetailView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("From: \(message.sender)")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 8)
            
                // Message content styled as a "bubble"
            Text(message.content)
                .font(.body)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer() // Push content to the top
        }
        .padding()
        .navigationTitle("Message")
    }
}


struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
