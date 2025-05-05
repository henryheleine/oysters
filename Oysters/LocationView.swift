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
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        if locationManager.hasLocation {
            Text("Location: \(locationManager.country)").padding(.bottom, 15).foregroundStyle(Color(UIColor.darkGray))
        } else {
            Button("Add location\n(improved precision)") {
                locationManager.checkLocationAuthorization()
            }
            .disabled(viewModel.image != nil)
        }
    }
}
