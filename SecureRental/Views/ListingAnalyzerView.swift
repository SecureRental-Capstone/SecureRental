import Foundation
import SwiftUI

struct ScamScoreView: View {
    let listing: Listing
    @Environment(\.dismiss) var dismiss

    @State private var analysisResult: ListingAnalysisResult? = nil
    @State private var isLoading = false
    @EnvironmentObject var viewModel: ChatbotViewModel
    
    private let apiKey = "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"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Analyzing listing...")
                        .font(.title2.bold())
                        .padding(.vertical, 50)
                } else if let result = analysisResult {
                    ReportContent(result: result)
                } else {
                    // Added a more informative failure message
                    Text("Analysis failed to start or complete. Check API keys and network connection.")
                        .foregroundColor(.red)
                        .padding(.vertical, 50)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Integrity Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        // Analysis starts immediately when the sheet is presented
        .task {
            await performAnalysis()
        }
    }
    
    // MARK: - API Functions

    func checkListingDiscrepancy(listing: Listing, apiKey: String) async -> DiscrepancyResult {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        let prompt = """
        "You are an expert AI assistant specialized in vetting real estate rental listings for quality and potential fraud risks.

        Analyze the listing content and specifications below for the following issues:
        1.  **Contradictions/Discrepancies:** Do the title, description, and specifications contradict each other?
        2.  **Completeness & Quality:** Is the description meaningful, detailed, and relevant to a rental listing? **Flag placeholder text (like 'lorem ipsum') or overly brief/generic descriptions as a discrepancy.**
        3.  **Misleading Language:** Is the title or description misleading or overly vague?

        Listing Title: "\(listing.title)"
        Listing Description: "\(listing.description)"
        Specifications:
        - Number of Bedrooms: \(listing.numberOfBedrooms)
        - Number of Bathrooms: \(listing.numberOfBathrooms)

        **CRITICAL RULE:** If the Listing Description appears to be placeholder text, is non-specific, or is less than 50 characters, you **must** set "discrepancy_detected" to **true** and explain the lack of detail in the "details" field.

        Respond only with a JSON object with the following structure:
        {
            "discrepancy_detected": true/false,
            "details": "Explanation of any discrepancies, including irrelevant or placeholder descriptions."
        }
        """
        
        let requestBody = ChatRequest(
            model: "gpt-4o-mini",
            messages: [
                AnalyzerMessage(role: "system", content: "You are a helpful assistant."),
                AnalyzerMessage(role: "user", content: prompt)
            ]
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            struct OpenAIResponse: Codable {
                struct Choice: Codable {
                    struct Message: Codable {
                        let content: String
                    }
                    let message: Message
                }
                let choices: [Choice]
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            let content = openAIResponse.choices.first?.message.content ?? ""
            
            if let jsonData = content.data(using: .utf8),
               let result = try? JSONDecoder().decode(DiscrepancyResult.self, from: jsonData) {
                return result
            } else {
                // Log the raw AI response if it fails to parse
                print("OpenAI JSON PARSE ERROR. Raw Content: \(content)")
                return DiscrepancyResult(discrepancy_detected: nil, details: "Raw AI Output: \(content)")
            }
        } catch {
            print("OpenAI API ERROR: \(error.localizedDescription)")
            return DiscrepancyResult(discrepancy_detected: nil, details: "API Error: \(error.localizedDescription)")
        }
    }

    func checkImageUrlIsAI(_ imageUrl: String) async throws -> Double {
        var components = URLComponents(string: "https://api.sightengine.com/1.0/check.json")!
        components.queryItems = [
            URLQueryItem(name: "url", value: imageUrl),
            URLQueryItem(name: "models", value: "genai"),
            URLQueryItem(name: "api_user", value: "535122157"),
            URLQueryItem(name: "api_secret", value: "d7ZjjRV3SDZondvyiiG3GFcQG92yxkn6")
        ]
        let url = components.url!
        
        // Added print statement for debugging failed requests
        print("Checking image URL: \(imageUrl)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorDetails = String(data: data, encoding: .utf8) ?? "No response body."
            print("Sightengine HTTP Error \(httpResponse.statusCode): \(errorDetails)")
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(SightEngResponse.self, from: data)
        return decoded.type.ai_generated
    }
        
    private func performAnalysis() async {
        // 1. Set Loading State
        await MainActor.run {
            self.isLoading = true
            self.analysisResult = nil
        }
        
        defer {
            Task { @MainActor in self.isLoading = false }
        }
        
        do {
            // 2. Run Content Check Concurrently
            async let discrepancyCheck = checkListingDiscrepancy(
                listing: listing,
                apiKey: apiKey
            )
            
            // 3. Run All Image Checks Concurrently using TaskGroup
            let imageScores: [Double] = await withTaskGroup(of: Double.self, returning: [Double].self) { group in
                var scores: [Double] = []
                
                for url in listing.imageURLs {
                    group.addTask {
                        return (try? await checkImageUrlIsAI(url)) ?? -1.0
                    }
                }
                
                for await score in group {
                    scores.append(score)
                }
                return scores
            }
            
            // 4. Combine Results
            let result = ListingAnalysisResult(
                discrepancy: await discrepancyCheck,
                aiImageScores: imageScores
            )
            
            await MainActor.run {
                self.analysisResult = result
            }
        } catch {
            //catching crashes
            print("CRITICAL ANALYSIS RUNTIME ERROR: \(error.localizedDescription)")
            //provide a failure result to display something on the screen
            let errorResult = ListingAnalysisResult(
                discrepancy: DiscrepancyResult(discrepancy_detected: true, details: "Fatal error: \(error.localizedDescription)"),
                aiImageScores: []
            )
            await MainActor.run {
                self.analysisResult = errorResult
            }
        }
    }
}

struct ReportContent: View {
    let result: ListingAnalysisResult

        var body: some View {
            // The main scrollable area with a light background for the cards to pop
            ScrollView {
                VStack(spacing: 16) {

                    VStack(alignment: .leading, spacing: 10) {

                        // Card Header
                        HStack {
                            Text("Content Discrepancy Check")
                                .font(.headline)
                            Spacer()
                        }
                        .padding([.top, .horizontal])

                        Divider()

                        // Risk Status
                        HStack {
                            if result.discrepancy.discrepancy_detected ?? false {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("HIGH RISK")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("LOW RISK")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(result.discrepancy.discrepancy_detected ?? false ? Color.red : Color.green)

                        // Details
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Details:")
                                .font(.body)
                                .fontWeight(.semibold)

                            Text(result.discrepancy.details)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding([.horizontal, .bottom])

                    }
                    // Card styling
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                    VStack(alignment: .leading, spacing: 10) {

                        // Card Header
                        Text("Image AI Generation Check")
                            .font(.headline)
                            .padding([.top, .horizontal])

                        Divider()

                        // List of Image Scores
                        VStack(spacing: 12) {
                            if result.aiImageScores.isEmpty {
                                Text("No images available for AI check.")
                                    .foregroundColor(.orange)
                                    .frame(maxWidth: .infinity)
                            } else {
                                ForEach(Array(result.aiImageScores.enumerated()), id: \.offset) { index, score in
                                    let percentage = score * 100

                                    HStack {
                                        Text("Image \(index + 1) Likelihood")
                                            .font(.body)

                                        Spacer()

                                        // Percentage text
                                        Text("\(String(format: "%.1f%%", percentage))")
                                            .fontWeight(.semibold)
                                            .foregroundColor(percentage > 50 ? .red : .primary)

                                        // Progress bar
                                        ProgressView(value: min(max(score, 0.0), 1.0), total: 1.0)
//                                        ProgressView(value: score, total: 1.0)
                                            .progressViewStyle(LinearProgressViewStyle(tint: percentage > 50 ? .red : .blue))
                                            .frame(width: 50)
                                    }
                                }
                            }
                        }
                        .padding([.horizontal, .bottom])

                    }
                    // Card styling
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                } // End of main VStack
                .padding(.horizontal)
                .padding(.vertical, 20)

            } // End of ScrollView
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)) // Light gray background
            .navigationTitle("AI Integrity Report")
        }
    
}
