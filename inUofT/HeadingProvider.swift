//
//  HeadingProvider.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-01.
//

import Foundation
import CoreLocation
import Combine

class HeadingProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentHeading: CLLocationDirection?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.headingFilter = 1
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }
}
