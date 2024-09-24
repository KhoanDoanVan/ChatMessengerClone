//
//  CurrentLocationSheetViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 23/9/24.
//

import Foundation
import MapKit
import CoreLocation

class CurrentLocationSheetViewModel: NSObject, ObservableObject,  CLLocationManagerDelegate{
    @Published var location: CLLocationCoordinate2D = .userLocation
    @Published var nameLocation: String = "Unknown Location"
    
    var locationManager: CLLocationManager?
    let geocoder = CLGeocoder() // Storage geocoder to get name of location
    
    /// Check Enable from CLLocationManager
    func checkIfLocationServicesIsEnable() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        } else {
            print("CLLocationManager is denied enable.")
        }
    }
    
    /// Check permissions
    private func checkAuthorized() {
        guard let locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("not Determined")
        case .restricted:
            print("Location manager restricted.")
        case .denied:
            print("Location manager denied")
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            if let cllLocation: CLLocation = locationManager.location {
                self.location = CLLocationCoordinate2D(latitude: cllLocation.coordinate.latitude, longitude: cllLocation.coordinate.longitude)
                print("Authorized success with current location: \(location)")
                
                getLocationName(from: cllLocation)
            }
        default:
            print("Default")
            break
        }
    }
    
    /// Did change
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorized()
    }
    
    /// Get name of location
    private func getLocationName(from location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            
            if let error = error {
                print("Failed getLocationName: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                let name = placemark.name ?? "unknown"
                let city = placemark.locality ?? "unknown"
                let country = placemark.country ?? "unknown"
                
                self.nameLocation = "\(name), \(city), \(country)"
                print("Location: \(nameLocation)")
            }
        }
    }
}
