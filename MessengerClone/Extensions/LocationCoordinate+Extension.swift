//
//  LocationCoordinate+Extension.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 23/9/24.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
    }
    
    static var userRegionFarmore: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 1500, longitudinalMeters: 1500)
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 10.742822233852860, longitude: 106.685750)
    }
}
