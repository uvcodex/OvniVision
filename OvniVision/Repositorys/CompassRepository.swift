//
//  CompassRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/16/26.
//

import Foundation
import CoreLocation

// MARK: - Compass data source

protocol CompassApi {
    var heading: Double { get }
}

@Observable
final class CompassRepository: NSObject, CompassApi {
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }
    
    private let locationManager = CLLocationManager()
    private var smoothed: Double = 0
    
    var heading: Double = 0
    
    
    /// Low-pass filter with 0/360 wraparound handling.
    nonisolated private func lowPass(current: Double, new: Double, alpha: Double = 0.25) -> Double {
        var diff = new - current
        if diff >  180 { diff -= 360 }
        if diff < -180 { diff += 360 }
        var result = current + alpha * diff
        if result <   0 { result += 360 }
        if result >= 360 { result -= 360 }
        return result
    }
}

extension CompassRepository:  CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        let current = smoothed
        let raw = newHeading.magneticHeading
        Task.detached {
            let s = self.lowPass(current: current, new: raw)
            await MainActor.run {
                self.smoothed = s
                self.heading = s
            }
        }
        
    }
}
