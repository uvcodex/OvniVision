//
//  CompassRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/16/26.
//

import Foundation
import CoreLocation

// MARK: - Compass data source

@Observable
final class CompassRepository: NSObject, CLLocationManagerDelegate {
    
    var heading: Double = 0
    
    private let locationManager = CLLocationManager()
    private var smoothed: Double = 0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        smoothed = lowPass(current: smoothed, new: newHeading.magneticHeading)
        heading = smoothed
    }
    
    /// Low-pass filter with 0/360 wraparound handling.
    private func lowPass(current: Double, new: Double, alpha: Double = 0.25) -> Double {
        var diff = new - current
        if diff >  180 { diff -= 360 }
        if diff < -180 { diff += 360 }
        var result = current + alpha * diff
        if result <   0 { result += 360 }
        if result >= 360 { result -= 360 }
        return result
    }
}
