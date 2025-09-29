//
//  CloudinaryHelper.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//

import UIKit

struct CloudinaryHelper {
    static let cloudName = "diudhiphg"
    static let uploadPreset = "secure_rental_upload"

    static func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "Cloudinary", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
        }

        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add upload preset
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(uploadPreset)\r\n".data(using: .utf8)!)

        // Add image file
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(UUID().uuidString).jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let (responseData, _) = try await URLSession.shared.upload(for: request, from: data)
        let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any]

        if let urlString = json?["secure_url"] as? String {
            return urlString
        } else {
            throw NSError(domain: "Cloudinary", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL"])
        }
    }
}
