//
//  ContentView.swift
//  Oysters
//
//  Created by Henry Heleine on 2/20/25.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var pickerItem: PhotosPickerItem?
    @State private var image: Image?
    private var base64ImageData: String?
    
    var body: some View {
        VStack {
            Image(systemName: "fish")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Oysters!")
            PhotosPicker("Select a picture", selection: $pickerItem)
            VStack {
                if let image = image {
                    image.resizable().scaledToFit()
                }
            }
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
        let uiImage = ImageRenderer(content: image!.resizable().frame(width: 250, height: 250)).uiImage!
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
            let jsonData = try JSONEncoder().encode(json)
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        print("1")
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("2")
            if let error = error {
                print("Network error: \(error)")
                return
            }
            print("3")
            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("4")
            if httpResponse.statusCode == 200 {
                print("5")
                print("POST request successful")
            } else {
                print("POST request failed with status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
