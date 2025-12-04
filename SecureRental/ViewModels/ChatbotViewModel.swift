//
//  ChatbotViewModel.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.

import SwiftUI
import Combine
import Foundation
import CoreLocation
import Firebase


class ChatbotViewModel: ObservableObject {

    @Published private var userInput: String = ""
    @Published private var resultText: String = ""
    @Published private var coordinates: CLLocationCoordinate2D? = nil
    @Published private var filteredListings: [Listing] = []

    let db = Firestore.firestore()
    @Published var messages: [ChatbotMessage] = []
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    // Using FireDBHelper singleton to handle user data
    private var dbHelper: FireDBHelper?

    // TODO: Replace with your real OpenAI API key securely
    private let apiKey = "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"
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    init() {
        // Call getInstance asynchronously to ensure thread safety
        Task {
            self.dbHelper = await FireDBHelper.getInstance()

           
            DispatchQueue.main.async {
                let name = self.dbHelper?.currentUser?.name ?? "Friend"
                self.messages.append(ChatbotMessage(
                    text: "Hi \(name)! I'm here to help international students navigate housing. Ask me anything about renting apartments, required documents, finding roommates, or understanding the rental process!",
                    isUser: false,
                    timestamp: Date()
                ))
            }
        }
    }
    
   
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Add user's message to local array
        let userMessage = ChatbotMessage(text: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        isLoading = true
        
        let maxMessages = 20
        if messages.count > maxMessages {
            messages = Array(messages.suffix(maxMessages))
        }
        
        // Check if the query seems related to rental listings
        checkRentalQuery(text) { isRentalQuery in
            if isRentalQuery {
                self.userInput = text
                // If it's a rental query, process the query with processQuery
                self.processQuery()  // This already handles calling `queryOpenAIForParsing` and fetching listings
                print(self.filteredListings)
            } else {
                //  Build the full conversation history
                var history: [[String: String]] = []
                
                // SYSTEM MESSAGE FIRST
                history.append([
                    "role": "system",
                    "content": """
            You are SecureRental Bot — a friendly, knowledgeable assistant for international students using the rental app. 
            
            Rules:
            - Only answer rental, housing, or app-related questions.
            - If users ask about unrelated topics, politely redirect.
            - Provide clear, simple guidance useful for newcomers to countries.
            - You can ask clarifying questions if needed.
            
            App features include: login, signup with ID verification, home feed with rental listings, messages, favorites, profile, AI chatbot, search, add listing, and listing management.
            """
                ])
                
                // ADD ENTIRE CHAT HISTORY
                for msg in self.messages {
                    history.append([
                        "role": msg.isUser ? "user" : "assistant",
                        "content": msg.text
                    ])
                }
                
                //  Build request body
                let body: [String: Any] = [
                    "model": "gpt-4o-mini",
                    "messages": history
                ]
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
                    print("Error: Failed to encode JSON body")
                    self.isLoading = false
                    return
                }
                
                //  Build request
                var request = URLRequest(url: self.apiURL)
                request.httpMethod = "POST"
                request.addValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                // Send request
                URLSession.shared.dataTaskPublisher(for: request)
                    .tryMap { data, response -> Data in
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                            throw URLError(.badServerResponse)
                        }
                        return data
                    }
                    .decode(type: OpenAIResponse.self, decoder: JSONDecoder())
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        if case .failure(_) = completion {
                            self?.messages.append(ChatbotMessage(
                                text: "Sorry, I couldn't get a response. Please try again!",
                                isUser: false,
                                timestamp: Date()
                            ))
                        }
                    }, receiveValue: { [weak self] response in
                        if let reply = response.choices.first?.message.content {
                            let botMessage = ChatbotMessage(text: reply, isUser: false, timestamp: Date())
                            self?.messages.append(botMessage)
                        }
                        self?.isLoading = false
                    })
                    .store(in: &self.cancellables)
            }
        }
    }
    
    // Function to get coordinates from place name
    func getCoordinates(from placeName: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(placeName) { placemarks, error in
            guard error == nil, let first = placemarks?.first, let location = first.location else {
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }

    // Function to call OpenAI API and parse the query for relevant details
    func queryOpenAIForParsing(query: String, completion: @escaping (Int?, Int?, String?, Double?, Double?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        Extract the following details from the query:

        Query: "\(query)"

        Please extract the following details:
            - Bedrooms: The number of bedrooms requested.
            - Bathrooms: The number of bathrooms requested.
            - Location: The location or place name.
            - minPrice: The minimum price (if specified).
            - maxPrice: The maximum price (if specified).
            - Handle cases like:
                - "under $1000" or "less than $1000" should be interpreted as minPrice = 0, maxPrice = 1000.
                - "between $1000 and $1200" should be interpreted as minPrice = 1000, maxPrice = 1200.
                - "within $1000" should be interpreted as minPrice = 0, maxPrice = 1000.
                - If no price is specified, return 0 for minPrice and null for maxPrice.
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are an assistant helping users find rental listings."],
                ["role": "user", "content": prompt]
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error serializing JSON")
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, nil, nil, nil, nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil, nil, nil, nil, nil)
                return
            }
            
            // Parse the AI response
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = jsonResponse?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    let bedrooms = self.extractBedroomCount(from: content)
                    let bathrooms = self.extractBathroomCount(from: content)
                    let location = self.extractLocation(from: content)
                    let (minPrice, maxPrice) = self.extractPrice(from: content)
                    
                    // Geocode the location
                    if let location = location {
                        self.getCoordinates(from: location) { coord in
                            self.coordinates = coord
                            print("Geocoded coordinates: \(coord?.latitude ?? 0), \(coord?.longitude ?? 0)")
                        }
                    }
                    
                    // Return the extracted values
                    completion(bedrooms, bathrooms, location, minPrice, maxPrice)
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
                completion(nil, nil, nil, nil, nil)
            }
        }.resume()
    }

 
    func extractBedroomCount(from text: String) -> Int? {
        if let range = text.range(of: "Bedrooms: \\d+", options: .regularExpression) {
            let bedroomString = text[range]
            let bedroomCount = bedroomString.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
            return Int(bedroomCount)
        }
        return nil
    }

    // Helper function
    func extractBathroomCount(from text: String) -> Int? {
        if let range = text.range(of: "Bathrooms: \\d+", options: .regularExpression) {
            let bathroomString = text[range]
            let bathroomCount = bathroomString.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
            return Int(bathroomCount)
        }
        return nil
    }

    // Helper function
    func extractLocation(from text: String) -> String? {
        if let range = text.range(of: "Location: .+", options: .regularExpression) {
            let locationString = text[range]
            let location = locationString.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
            return location
        }
        return nil
    }

    // Helper function 
    func extractPrice(from text: String) -> (minPrice: Double?, maxPrice: Double?) {
        let priceRegex = "(less than|under|between|from)?\\s?\\$([\\d,]+)(?:\\s?to\\s?\\$([\\d,]+))?"
        
        if let range = text.range(of: priceRegex, options: .regularExpression) {
            let priceString = text[range]
            var minPrice: Double?
            var maxPrice: Double?
            
            // Extract min and max prices from the pattern
            if let minRange = priceString.range(of: "\\$([\\d,]+)", options: .regularExpression) {
                let minPriceString = priceString[minRange]
                minPrice = Double(minPriceString.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression))
                
                // Now, safely attempt to extract maxPrice if "to" exists
                if let maxRange = priceString.range(of: "\\$([\\d,]+)", options: .regularExpression, range: minRange.upperBound..<priceString.endIndex) {
                    let maxPriceString = priceString[maxRange]
                    maxPrice = Double(maxPriceString.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression))
                }
            }
            
            return (minPrice, maxPrice)
        }
        
        return (nil, nil)
    }
    
    //uncomment if dont work
//    func processQuery() {
//        queryOpenAIForParsing(query: userInput) { bedrooms, bathrooms, location, minPrice, maxPrice in
//            // Create ListingFilter with extracted details
//            var filter = ListingFilter(minPrice: minPrice, maxPrice: maxPrice, bedrooms: bedrooms, bathrooms: bathrooms, location: location)
//
//            // If location is specified, geocode it to get latitude/longitude
//            if let location = location {
//                self.getCoordinates(from: location) { coord in
//                    if let coord = coord {
//                        // Update the filter with the geocoded coordinates
//                        filter.latitude = coord.latitude
//                        filter.longitude = coord.longitude
//                    }
//
//                    // Query Firestore with the updated filter
//                    self.fetchFilteredListings(filter: filter) { listings in
//                        self.filteredListings = listings
//                        if listings.isEmpty {
//                            self.resultText = "No listings found for your criteria."
//                        } else {
//                            self.resultText = "Found \(listings.count) listings."
//                        }
//                    }
//                }
//            } else {
//                // If no location, query Firestore based on other filters
//                self.fetchFilteredListings(filter: filter) { listings in
//                    self.filteredListings = listings
//                    if listings.isEmpty {
//                        self.resultText = "No listings found for your criteria."
//                    } else {
//                        self.resultText = "Found \(listings.count) listings."
//                    }
//                }
//            }
//        }
//    }
    // INSIDE ChatbotViewModel
    func processQuery() {
        // 1. Start by calling the OpenAI API to parse the user's input
        queryOpenAIForParsing(query: userInput) { bedrooms, bathrooms, location, minPrice, maxPrice in
            
            // 2. Initialize the filter struct with parsed details
            var filter = ListingFilter(minPrice: minPrice, maxPrice: maxPrice, bedrooms: bedrooms, bathrooms: bathrooms, location: location)

            // Define the block of code that runs AFTER fetching is complete (with or without location)
            let completionBlock: ([Listing]) -> Void = { listings in
                // All UI updates MUST be executed on the main thread
                DispatchQueue.main.async {
                    
                    // Update the ViewModel's state properties
                    self.filteredListings = listings // ✅ Updates the list property (observed by List view)
                    self.isLoading = false // ✅ Stop the loading indicator

                    // 3. Construct the result message for the chat interface
                    if listings.isEmpty {
                        let text = "I couldn't find any rental listings matching your criteria."
                        self.messages.append(ChatbotMessage(text: text, isUser: false, timestamp: Date()))
                    } else {
                        let count = listings.count
                        let text = "I found **\(count) rental listings** that match your criteria! Check them out below."
                        
                        // Append the message, including the structured list of listings
                        self.messages.append(ChatbotMessage(
                            text: text,
                            isUser: false,
                            timestamp: Date(),
                            attachedListings: listings // 👇 Attach the final filtered list
                        ))
                    }
                }
            }
            
            // 4. Handle Geocoding and Listing Fetching
            if let location = location {
                // If location is provided, we must geocode first.
                self.getCoordinates(from: location) { coord in
                    if let coord = coord {
                        // Update the filter with coordinates
                        filter.latitude = coord.latitude
                        filter.longitude = coord.longitude
                    }

                    // Query Firestore with the filter (including coordinates if successful)
                    self.fetchFilteredListings(filter: filter, completion: completionBlock)
                }
            } else {
                // If no location, query Firestore based on price/bed/bath filters only
                self.fetchFilteredListings(filter: filter, completion: completionBlock)
            }
        }
    }
    
    func filterListingsByLocation(listings: [Listing], filter: ListingFilter) -> [Listing] {
        guard let userLatitude = filter.latitude, let userLongitude = filter.longitude else {
            return listings // If no coordinates, return all listings
        }
        
        // Define a radius (for example, 5 km)
        let radiusInKm = 5.0
        
        return listings.filter { listing in
            guard let listingLat = listing.latitude, let listingLon = listing.longitude else {
                return false // Exclude listings without coordinates
            }
            
            // Calculate the distance between the user's location and the listing's location
            let distance = distanceBetween(lat1: userLatitude, lon1: userLongitude, lat2: listingLat, lon2: listingLon)
            
            // Include the listing if it's within the radius
            return distance <= radiusInKm
        }
    }

    // Helper function to calculate distance between two geographical points (latitude/longitude) in kilometers
    func distanceBetween(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0 // Radius of the Earth in kilometers
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return earthRadius * c // Distance in kilometers
    }
    
    func fetchFilteredListings(filter: ListingFilter, completion: @escaping ([Listing]) -> Void) {
        // Get a reference to the "listings" collection
        let collectionReference = db.collection("Listings")

        // Build a query from the collection reference by adding filters
        var query: Query = collectionReference

        // Apply filters to the query if available
        if let minPrice = filter.minPrice {
            print("Min Price: \(minPrice)")
            query = query.whereField("price", isGreaterThanOrEqualTo: minPrice)
        }

        if let maxPrice = filter.maxPrice {
            print("Max Price: \(maxPrice)")
            query = query.whereField("price", isLessThanOrEqualTo: maxPrice)
        }

        if let bedrooms = filter.bedrooms {
            print("Bedrooms: \(bedrooms)")
            query = query.whereField("numberOfBedrooms", isEqualTo: bedrooms)
        }

        if let bathrooms = filter.bathrooms {
            print("Bathrooms: \(bathrooms)")
            query = query.whereField("numberOfBathrooms", isEqualTo: bathrooms)
        }

        // Execute the query to get all the listings
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                completion([])
                return
            }

            // Print snapshot to debug
            print("Firestore Snapshot: \(String(describing: snapshot!))")

            guard let documents = snapshot?.documents else {
                print("No documents found")
                completion([])
                return
            }

            // Map the Firestore documents to Listing objects
            var listings = documents.compactMap { doc -> Listing? in
                do {
                    let listing = try doc.data(as: Listing.self)
                    print("Listing fetched: \(listing)")  // Print the fetched listing for debugging
                    return listing
                } catch {
                    print("Error decoding listing: \(error.localizedDescription)")
                    return nil
                }
            }

            // Debugging: Print the final listings array
            print("Listings array: \(listings)")

            // Filter the listings by location (distance)
            let filteredListings = self.filterListingsByLocation(listings: listings, filter: filter)

            // Debugging: Print the filtered listings after location filter
            print("Filtered Listings: \(filteredListings)")

            // Return the filtered listings
            completion(filteredListings)
        }
    }
    // 2️⃣ Check if the query seems related to rental listings
    func checkRentalQuery(_ text: String, completion: @escaping (Bool) -> Void) {
        // Keywords related to rental listings
        let rentalKeywords = ["bed", "beds", "bath", "baths", "bedroom", "bathroom", "bedrooms", "bathrooms"]
        
        // Convert the user's query to lowercase for case-insensitive comparison
        let lowercasedText = text.lowercased()

        // Check if the query contains any rental-related keyword
        let isRentalQuery = rentalKeywords.contains(where: { lowercasedText.contains($0) })
        
        if isRentalQuery {
            print("This is a rental listing query")
        } else {
            print("This is not a rental listing query")
        }
        
        // Return the result to the caller
        completion(isRentalQuery)
    }

}

// MARK: - OpenAI API Response Models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
}
