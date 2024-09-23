//
//  CurrentLocationSheetViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 23/9/24.
//

import Foundation
import MapKit

class CurrentLocationSheetViewModel: NSObject, ObservableObject,  CLLocationManagerDelegate{
    @Published var location: CLLocationCoordinate2D = .userLocation
    
    var locationManager: CLLocationManager?
    
    /// Check Enable from CLLocationManager
    func checkIfLocationServicesIsEnable() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
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
        case .restricted:
            print("Location manager restricted.")
        case .denied:
            print("Location manager denied")
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            location = CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
            print("Authorized success with current location: \(location)")
        default:
            break
        }
    }
    
    /// Did change
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkIfLocationServicesIsEnable()
    }
}
