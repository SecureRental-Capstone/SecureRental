//
//  PersonaHandler.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-10-04.
////
//import Persona2
//import UIKit
//
//class PersonaHandler: NSObject, InquiryDelegate {
//
//    func inquiryComplete(inquiryId: String, status: String, fields: [String : InquiryField]) {
//        
//        print("✅ Inquiry Complete")
//        print("ID:", inquiryId)
//        print("Status:", status)
//        print("Fields:", fields)
//        
//        switch status {
//        case "completed":
//            // The user successfully verified their ID
//            print("User verification succeeded")
//            // Update your SwiftUI state here (e.g., move to main app)
//        case "declined":
//            // Persona rejected the verification
//            print("User verification denied")
//            // Show an alert or handle denial
//        case "pending_review":
//            // The verification is under review
//            print("User verification pending review")
//            // Optional: notify user that results are pending
//        default:
//            break
//        }
//    }
//
//    func inquiryCanceled(inquiryId: String?, sessionToken: String?) {
//        print("⚠️ Inquiry Canceled by user")
//        print("ID:", inquiryId ?? "nil")
//        print("Session token:", sessionToken ?? "nil")
//    }
//
//    func inquiryEventOccurred(event: InquiryEvent) {
//        print("📌 Inquiry Event:", event)
//        // This fires many times throughout the flow
//    }
//
//    func inquiryError(_ error: Error) {
//        print("❌ Inquiry Error:", error.localizedDescription)
//    }
//}
//
//class PersonaWrapperVC: UIViewController {
//
//    var onDismiss: (() -> Void)?
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        // Persona callback did NOT fire — meaning user exited using the X button
//        onDismiss?()
//    }
//}

import Persona2
import UIKit

class PersonaHandler: NSObject, InquiryDelegate {

    // 💡 Add a property to hold the dismissal action
        var onFlowDismissed: (() -> Void)?

        func inquiryComplete(inquiryId: String, status: String, fields: [String : InquiryField]) {
            print("✅ Inquiry Complete")
            
            // ⚠️ Crucial Step 1: Dismiss the UIViewController when done
            // When the flow completes, we must dismiss the wrapperVC.
            // The closure passed from the VerificationView will handle the dismissal *and* the navigation.
            self.onFlowDismissed?()

            // ... (rest of the inquiryComplete logic remains, including updating state)
        }

        func inquiryCanceled(inquiryId: String?, sessionToken: String?) {
            print("⚠️ Inquiry Canceled by user")
            
            // 🎯 Crucial Step 2: Execute the dismissal action on internal cancel
            self.onFlowDismissed?()
        }
    
//    func inquiryComplete(inquiryId: String, status: String, fields: [String : InquiryField]) {
//        
//        print("✅ Inquiry Complete")
//        print("ID:", inquiryId)
//        print("Status:", status)
//        print("Fields:", fields)
//        
//        switch status {
//        case "completed":
//            // The user successfully verified their ID
//            print("User verification succeeded")
//            // Update your SwiftUI state here (e.g., move to main app)
//        case "declined":
//            // Persona rejected the verification
//            print("User verification denied")
//            // Show an alert or handle denial
//        case "pending_review":
//            // The verification is under review
//            print("User verification pending review")
//            // Optional: notify user that results are pending
//        default:
//            break
//        }
//    }

//    func inquiryCanceled(inquiryId: String?, sessionToken: String?) {
//        print("⚠️ Inquiry Canceled by user")
//        print("ID:", inquiryId ?? "nil")
//        print("Session token:", sessionToken ?? "nil")
//    }

    func inquiryEventOccurred(event: InquiryEvent) {
        print("📌 Inquiry Event:", event)
        // This fires many times throughout the flow
    }

    func inquiryError(_ error: Error) {
        print("❌ Inquiry Error:", error.localizedDescription)
    }
}

class PersonaWrapperVC: UIViewController {

    var onDismiss: (() -> Void)?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // 🎯 Crucial Step 3: This fires if the user dismisses the VC externally (e.g., 'X' button)
        onDismiss?()
    }
}
