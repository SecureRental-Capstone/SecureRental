//
//  PersonaHandler.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-10-04.
//
import Persona2

class PersonaHandler: NSObject, InquiryDelegate {
    
    // Called when the inquiry is successfully completed
    func inquiryComplete(inquiryId: String, status: String, fields: [String : InquiryField]) {
        print("✅ Inquiry Complete!")
        print("Inquiry ID: \(inquiryId), Status: \(status), Fields: \(fields)")
    }
    
    // Called if the user cancels the flow
    func inquiryCanceled(inquiryId: String?, sessionToken: String?) {
        print("⚠️ Inquiry Canceled by user. ID: \(inquiryId ?? "N/A")")
    }
    
    // Called on error
    func inquiryError(_ error: Error) {
        print("❌ Inquiry Error: \(error.localizedDescription)")
    }
}

