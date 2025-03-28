//
//  LocationManager.swift
//  Oysters
//
//  Created by Henry Heleine on 3/17/25.
//

import CoreLocation
import Foundation
import SwiftUI

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var manager: CLLocationManager
    @Published public var country: String
    @Published public var hasLocation: Bool
    
    init(manager: CLLocationManager = CLLocationManager(), country: String = "Unknown", hasLocation: Bool = false) {
        self.manager = manager
        self.country = country
        self.hasLocation = hasLocation
    }
    
    func checkLocationAuthorization() {
        manager.delegate = self
        manager.startUpdatingLocation()
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways, .denied, .restricted:
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first?.coordinate else { return }
        
        let location = CLLocation(latitude: first.latitude, longitude: first.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            guard let placemarks = placemarks else { return }
            guard placemarks.count > 0 else { return }
            guard let country = placemarks[0].country else { return }
            
            self.country = country
            self.hasLocation = true
        })
        
        manager.stopUpdatingLocation()
    }
}
