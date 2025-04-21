//
//  LocationView.swift
//  Oysters
//
//  Created by Henry Heleine on 4/21/25.
//

import Foundation
import SwiftUI

struct LocationView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var model: Model
    
    var body: some View {
        if locationManager.hasLocation {
            Text("Location: \(locationManager.country)")
                .padding(.bottom, 15)
                .foregroundStyle(Color.text)
        } else {
            Button("Add location\n(improved precision)") {
                locationManager.checkLocationAuthorization()
            }
            .disabled(model.image != nil)
        }
    }
}
