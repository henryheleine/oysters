//
//  ViewModel.swift
//  Oysters
//
//  Created by Henry Heleine on 3/20/25.
//

import Combine
import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    @Published var image: Image?
    @Published var response: OpenApiResponse?
    @ObservedObject var locationManager: LocationManager
    
    init(json: [String : String] = [String: String](),
         image: Image? = nil,
         response: OpenApiResponse? = nil,
         locationManager: LocationManager) {
        self.image = image
        self.response = response
        self.locationManager = locationManager
    }
    
    func fetchStream(completion: @escaping (Result<OpenApiResponse?, Error>) -> ()) async {
        guard let url = URL(string: "https://www.example.com/stream") else { return } // TODO: replace with final url and refactor into a "NetworkService"
        do {
            var request = URLRequest(url: url)
            let json = ["imageData": await base64(fromImage: image)]
            let jsonData = try JSONEncoder().encode(json)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
            request.addValue("keep-alive", forHTTPHeaderField: "Connection")
            request.httpBody = jsonData
            request.httpMethod = "POST"
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return completion(.failure(NSError(domain: "Error with response status code", code: -1)))
            }
            var iterator = bytes.makeAsyncIterator()
            while let byte = try await iterator.next() {
                var data = Data()
                data.append(byte)
                let chunk = String(data: data, encoding: .utf8) ?? ""
                Task { @MainActor in
                    NotificationCenter.default.post(name: NSNotification.oysterUpdate, object: chunk)
                }
            }
            completion(.success(nil))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    @MainActor func base64(fromImage: Image?) async -> String {
        let render = ImageRenderer(content: image?.resizable().frame(width: 250, height: 250))
        render.isOpaque = true
        if let uiImage = render.uiImage {
            if let data = uiImage.jpegData(compressionQuality: 1) {
                return data.base64EncodedString()
            }
        }
        return ""
    }
    
    func reset() {
        image = nil
        response = nil
    }
    
    private func updateErrorResponse() {
        Task { @MainActor in
            self.response = OpenApiResponse(content: "Information is not available at this time. Please check your internet connection and try again later.")
        }
    }
}
