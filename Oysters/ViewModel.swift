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
    var cancellables = Set<AnyCancellable>()
    @Published var image: Image?
    @Published var response: OpenApiResponse?
    @ObservedObject var locationManager: LocationManager
    
    init(cancellables: Set<AnyCancellable> = Set<AnyCancellable>(),
         json: [String : String] = [String: String](),
         image: Image? = nil,
         response: OpenApiResponse? = nil,
         locationManager: LocationManager) {
        self.cancellables = cancellables
        self.image = image
        self.response = response
        self.locationManager = locationManager
    }
    
    func requestInfo(completion: (() -> Void)? = nil) async {
        do {
            var request = URLRequest(url: URL(string: "https://www.example.com/data")!) // TODO: replace with final url and refactor into a "NetworkService"
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            var json = (locationManager.country != "Unknown") ? ["country": locationManager.country] : [String: String]()
            json["imageData"] = await base64(fromImage: image)
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
                    receiveCompletion: { [weak self] status in
                        guard let weakSelf = self else { return }
                        switch status {
                        case .finished:
                            break
                        case .failure(_):
                            weakSelf.updateErrorResponse()
                            if let completion = completion {
                                completion()
                            }
                            break
                        }
                    },
                    receiveValue: { response in
                        Task { @MainActor in
                            self.response = response
                            if let completion = completion {
                                completion()
                            }
                        }
                    }
                )
                .store(in: &cancellables)
        } catch _ {
            updateErrorResponse()
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
        cancellables.first?.cancel()
    }
    
    private func updateErrorResponse() {
        Task { @MainActor in
            self.response = OpenApiResponse(content: "Information is not available at this time. Please check your internet connection and try again later.")
        }
    }
}
