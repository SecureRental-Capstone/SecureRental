//
//  PersonaHandler.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-10-04.

import Persona2
import UIKit

class PersonaHandler: NSObject, InquiryDelegate {
    
    //  Add a property to hold the dismissal action
    var onFlowDismissed: (() -> Void)?
    var dbHelper: FireDBHelper?

    init(dbHelper: FireDBHelper? = nil) {
        self.dbHelper = dbHelper
    }

    func inquiryComplete(inquiryId: String, status: String, fields: [String : InquiryField]) {
        
        print(" Inquiry Complete")
        print("ID:", inquiryId)
        print("Status:", status)
        print("Fields:", fields)
        
        guard let dbHelper = dbHelper else {
            print(" dbHelper not set on PersonaHandler")
            onFlowDismissed?()
            return
        }

        guard let user = dbHelper.currentUser else {
            print(" No current user in dbHelper")
            onFlowDismissed?()
            return
        }
        
        
        Task {
            user.isVerified = true
            await dbHelper.updateUser(user: user)
            print(" isVerified saved to database")
        }
        
        onFlowDismissed?()   // DISMISS FLOW
    }

    func inquiryCanceled(inquiryId: String?, sessionToken: String?) {
        print(" Inquiry Canceled by user")
        print("ID:", inquiryId ?? "nil")
        print("Session token:", sessionToken ?? "nil")
        
        onFlowDismissed?()   // DISMISS FLOW
    }

    func inquiryEventOccurred(event: InquiryEvent) {
        print(" Inquiry Event:", event)
        // This fires many times throughout the flow
    }

    func inquiryError(_ error: Error) {
        print(" Inquiry Error:", error.localizedDescription)
    }
}

class PersonaWrapperVC: UIViewController {

    var onDismiss: (() -> Void)?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

       
        onDismiss?()
    }
}
