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
            Color("Background").ignoresSafeArea()
            ScrollView() {
                Text("Oyster Identification")
                    .font(Font.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.text)
                    .padding(.top, 60)
                    .padding(.bottom, 5)
                    .accessibilityLabel("Oyster Identification")
                LocationView(locationManager: locationManager, model: model)
                Spacer()
                    .frame(height: 30)
                if let image = model.image {
                    HStack {
                        Text("")
                            .padding(.leading, 50)
                            .foregroundStyle(Color.background)
                        Spacer()
                        Text("Picture:")
                            .foregroundStyle(Color.text)
                        Spacer()
                        Button {
                            reset()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.text)
                        }
                        .padding(.trailing, 15)
                    }
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: dimensionForDevice(), height: dimensionForDevice())
                        .padding(.bottom, 15)
                    OutcomeView(model: model)
                } else {
                    Spacer().frame(height: 180)
                    PhotosPicker("Tap to select picture", selection: $pickerItem)
                }
                Spacer()
            }
            .font(Font.system(size: 24))
        }
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
    
    private func dimensionForDevice() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .phone ? 300 : 500
    }
    
    private func reset() {
        model.reset()
        pickerItem = PhotosPickerItem(itemIdentifier: "\(UUID())")
    }
}

#Preview {
    ContentView()
}
