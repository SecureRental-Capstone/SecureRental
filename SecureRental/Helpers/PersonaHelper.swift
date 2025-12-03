//
//  PersonaHelper.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-10-04.
//
import Foundation
import Persona2

func createPersonaInquiry(firstName: String, lastName: String, birthdate: String, completion: @escaping (Result<String, Error>) -> Void) {

    let personaApiKey = "persona_sandbox_523fab99-f012-46f9-83bd-7e6a670d37a4" 
    let inquiryTemplateId = "itmpl_nvQHE8ZVjUwbZNKB899ert8acgEC" //gov id + selfie
    //let inquiryTemplateId = "itmpl_eLK9ZMhAu6qtueLjChQgbyeGUuPM" //gov id + selfie + proof of address
    
    guard let url = URL(string: "https://api.withpersona.com/api/v1/inquiries") else {
        completion(.failure(NSError(domain: "PersonaAPI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // 1. Set Headers
    request.setValue("2023-01-05", forHTTPHeaderField: "Persona-Version")
    request.setValue("application/json", forHTTPHeaderField: "accept")
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    request.setValue("Bearer \(personaApiKey)", forHTTPHeaderField: "authorization")
    
    // 2. Prepare JSON Body
    let body: [String: Any] = [
        "data": [
            "attributes": [
                "inquiry-template-id": inquiryTemplateId,
                "fields": [
                    "name-first": firstName,
                    "name-last": lastName,
                    "birthdate": birthdate
                ]
            ]
        ]
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        completion(.failure(error))
        return
    }

    // 3. Execute the Request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "PersonaAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        do {
            // Attempt to parse the JSON response
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let dataDict = jsonResponse["data"] as? [String: Any],
               let inquiryId = dataDict["id"] as? String {
                
                // Success: Return the Inquiry ID (inq_...)
                completion(.success(inquiryId))
                
            } else {
                // Handle non-standard or error response
                let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(.failure(NSError(domain: "PersonaAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Inquiry ID: \(responseString)"])))
            }
        } catch {
            completion(.failure(error))
        }

    }.resume()
}
