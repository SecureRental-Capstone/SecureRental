//
//  MessageView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2024-10-21.
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

    // Main view showing a list of contacts
struct MessageView: View {
    @Environment(\.dismiss) private var dismiss
    let contacts: [Contact] = sampleContacts
    
    var body: some View {
        NavigationView {
            List(contacts) { contact in
                NavigationLink(destination: MessageListView(contact: contact)) {
                    HStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding(5)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(25)
                        
                        Text(contact.name)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.leading, 10)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
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

    // View displaying messages in the selected contact's thread
struct MessageListView: View {
    let contact: Contact
    
    var body: some View {
        List(contact.messages) { message in
            VStack(alignment: .leading, spacing: 10) {
                Text(message.sender)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text(message.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
