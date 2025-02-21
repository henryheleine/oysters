//
//  ContentView.swift
//  Oysters
//
//  Created by Henry Heleine on 2/20/25.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    @State private var isCameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    
    var body: some View {
        VStack {
            Image(systemName: "fish")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Oysters!")
            Text("\(isCameraAuthorized)")
        }
        .onAppear() {
            requestCameraAuth()
        }
        .padding()
    }
    
    private func requestCameraAuth() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined else { return }
        
        AVCaptureDevice.requestAccess(for: .video) { isAuthorized in
            DispatchQueue.main.async {
                self.isCameraAuthorized = isAuthorized
            }
        }
    }
}

#Preview {
    ContentView()
}
