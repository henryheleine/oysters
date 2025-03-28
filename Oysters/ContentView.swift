//
//  ContentView.swift
//  Oysters
//
//  Created by Henry Heleine on 2/20/25.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var model: Model
    @State private var pickerItem: PhotosPickerItem?
    
    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        self.model = Model(locationManager: locationManager)
    }
    
    var body: some View {
        ZStack {
            Color(red: 201/256, green: 172/256, blue: 172/256, opacity: 1)
            VStack(spacing: 10) {
                Text("Oyster Identification")
                    .padding(.top, 60)
                if locationManager.hasLocation {
                    Text("Location: \(locationManager.country)")
                    if let image = model.image {
                        HStack {
                            Spacer()
                            Text("Picture:")
                            Spacer()
                            Button {
                                reset()
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .padding(.trailing, 15)
                        }
                        image.resizable().scaledToFit().frame(width: 500, height: 500)
                        OutcomeView(model: model)
                    } else {
                        PhotosPicker("Tap to select picture", selection: $pickerItem)
                    }
                } else {
                    Button("Add optional location? (better precision)") {
                        locationManager.checkLocationAuthorization()
                    }
                }
                Spacer()
            }
            .font(Font.system(size: 24))
        }
        .ignoresSafeArea()
        .onAppear() {
            let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://render-4ezx.onrender.com/")!))
            task.resume()
        }
        .onChange(of: pickerItem) {
            Task {
                model.image = try await pickerItem?.loadTransferable(type: Image.self)
                Task {
                    guard let _ = model.image else { return }
                    await model.requestInfo()
                }
            }
        }
    }
    
    private func reset() {
        model.reset()
        pickerItem = PhotosPickerItem(itemIdentifier: "\(UUID())")
    }
}

#Preview {
    ContentView()
}
