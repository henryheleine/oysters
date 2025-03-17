//
//  ContentView.swift
//  Oysters
//
//  Created by Henry Heleine on 2/20/25.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var pickerItem: PhotosPickerItem?
    @State private var image: Image?
    @State private var outcome: String?
    private var base64ImageData: String?
    
    var body: some View {
        ZStack {
            Color(red: 201/256, green: 160/256, blue: 220/256, opacity: 1)
            VStack(spacing: 10) {
                Spacer().frame(height: 15)
                Text("Oyster Identification")
                if let country = locationManager.country {
                    Text("Location: \(country)")
                    if let image = image {
                        Text("Picture:")
                        HStack {
                            Spacer()
                            Button {
                                print("clear")
                            } label: {
                                Image(systemName: "xmark").foregroundStyle(.white)
                            }
                            Spacer().frame(width: 15)
                        }
                        image.resizable().scaledToFit()
                        Text("Response:")
                        if let outcome = outcome {
                            ScrollView {
                                Text(outcome)
                            }
                        } else {
                            ProgressView()
                        }
                    } else {
                        PhotosPicker("Select a picture", selection: $pickerItem)
                    }
                } else {
                    Button("Tap to get location (better precision)") {
                        locationManager.checkLocationAuthorization()
                    }
                }
                Spacer()
            }
            .font(Font.system(size: 24))
        }
        .onAppear() {
            URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://render-4ezx.onrender.com/")!)).resume()
        }
        .onChange(of: pickerItem) {
            Task {
                image = try await pickerItem?.loadTransferable(type: Image.self)
            }
        }
        .onChange(of: image) {
            Task {
                await requestInfo()
            }
        }
    }
    
    private func base64(fromImage: Image?) async -> String {
        let render = ImageRenderer(content: image!.resizable().frame(width: 250, height: 250))
        render.isOpaque = true
        let uiImage = render.uiImage!
        if let data = uiImage.jpegData(compressionQuality: 1) {
            return data.base64EncodedString()
        }
        return ""
    }
    
    nonisolated func requestInfo() async {
        var request = URLRequest(url: URL(string: "https://render-4ezx.onrender.com/data")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            var json = [String: String]()
            json["imageData"] = await base64(fromImage: image)
            json["country"] = await locationManager.country
            let jsonData = try JSONEncoder().encode(json)
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 200 {
                if let data = data, let response = String(data: data, encoding: .utf8) {
                    Task { @MainActor in
                        outcome = response
                    }
                }
            } else {
                print("POST request failed with status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
