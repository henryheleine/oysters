//
//  Model.swift
//  Oysters
//
//  Created by Henry Heleine on 3/20/25.
//

import Combine
import Foundation
import SwiftUI

class Model: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var json = [String: String]()
    @Published var image: Image?
    @Published var response: OpenApiResponse?
    @ObservedObject var locationManager: LocationManager
    
    init(cancellables: Set<AnyCancellable> = Set<AnyCancellable>(),
         json: [String : String] = [String: String](),
         image: Image? = nil,
         response: OpenApiResponse? = nil,
         locationManager: LocationManager) {
        self.cancellables = cancellables
        self.json = json
        self.image = image
        self.response = response
        self.locationManager = locationManager
    }
    
    func requestInfo() async {
        do {
            var request = URLRequest(url: URL(string: "https://render-4ezx.onrender.com/data")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            json["imageData"] = await base64(fromImage: image)
            if locationManager.country != "Unknown" {
                json["country"] = locationManager.country
            }
            let jsonData = try JSONEncoder().encode(json)
            request.httpBody = jsonData
            
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { element -> Data in
                    guard let response = element.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: OpenApiResponse.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
                .sink(
                    receiveCompletion: { status in
                        switch status {
                        case .finished:
                            break
                        case .failure(let error):
                            print("ERROR: \(error)")
                            break
                        }
                    },
                    receiveValue: { response in
                        Task { @MainActor in
                            self.response = response
                        }
                    }
                )
                .store(in: &cancellables)
        } catch let error {
            print(error)
        }
    }
    
    @MainActor func base64(fromImage: Image?) async -> String {
        let render = ImageRenderer(content: image?.resizable().frame(width: 250, height: 250))
        render.isOpaque = true
        let uiImage = render.uiImage!
        if let data = uiImage.jpegData(compressionQuality: 1) {
            return data.base64EncodedString()
        }
        return ""
    }
    
    func reset() {
        image = nil
        response = nil
    }
}
