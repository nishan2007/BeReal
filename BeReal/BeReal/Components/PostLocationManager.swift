//
//  PostLocationManager.swift
//  BeReal
//
//  Created by Nishan Narain on 3/18/26.
//

import Foundation
import CoreLocation
import Combine

final class PostLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var locationName: String?
    @Published var locationError: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func requestLocationAccessAndFetch() {
        let status = manager.authorizationStatus

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .denied, .restricted:
            locationError = "Location access denied"
        @unknown default:
            locationError = "Unable to access location"
        }
    }

    func requestLocation() {
        let status = manager.authorizationStatus

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = "Location access denied"
        @unknown default:
            locationError = "Unable to access location"
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.locationError = "Location access denied"
            }
        case .notDetermined:
            break
        @unknown default:
            DispatchQueue.main.async {
                self.locationError = "Unable to access location"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            DispatchQueue.main.async {
                self.locationError = "Could not get location"
            }
            return
        }

        DispatchQueue.main.async {
            self.currentLocation = location
            self.locationError = nil
        }

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let city = placemark.locality
                    let state = placemark.administrativeArea
                    let country = placemark.country

                    if let city, let state {
                        self.locationName = "\(city), \(state)"
                    } else if let city, let country {
                        self.locationName = "\(city), \(country)"
                    } else if let name = placemark.name {
                        self.locationName = name
                    } else {
                        self.locationName = "Unknown location"
                    }
                } else if error != nil {
                    self.locationName = nil
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = error.localizedDescription
        }
    }
}
