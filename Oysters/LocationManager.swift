//
//  LocationManager.swift
//  Oysters
//
//  Created by Henry Heleine on 3/17/25.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var country: String?
    var manager = CLLocationManager()
    
    func checkLocationAuthorization() {
        manager.delegate = self
        manager.startUpdatingLocation()
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied, .authorizedAlways:
            print("do nothing")
        case .authorizedWhenInUse:
            lastKnownLocation = manager.location?.coordinate
        @unknown default:
            print("Location service disabled")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
        if let lastKnownLocation = lastKnownLocation {
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: lastKnownLocation.latitude, longitude: lastKnownLocation.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                if let placemarks = placemarks, placemarks.count > 0 {
                    let placemark = placemarks[0]
                    if let country = placemark.country {
                        self.country = country
                    }
                }
            })
        }
    }
}
