//
//  TrackObjectRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/16/26.
//

import CoreVideo
import Foundation
import Vision

@Observable
final class TrackObjectRepository {
    // MARK: - State
    var isTracking: Bool = false
    var isReadyToBegin: Bool = false
    /// Tracked bounding box in Vision normalized coords (bottom-left origin, 0–1).
    var trackedBounds: CGRect? = nil
    /// Set by PlaybackViewFinder to the Vision-space rect of the peephole before tracking starts.
    var peepholeNormalizedBox: CGRect = .zero

    private var currentObservation: VNDetectedObjectObservation? = nil
    private var sequenceHandler = VNSequenceRequestHandler()

    // MARK: - Control

    /// Called when the track button is pressed.
    func requestStart() {
        guard !peepholeNormalizedBox.isEmpty else { return }
        stopTracking()
        isReadyToBegin = true
    }

    func stopTracking() {
        isTracking = false
        isReadyToBegin = false
        currentObservation = nil
        trackedBounds = nil
    }

    // MARK: - Called by PlayerRepository

    /// Initialises tracking using the current peepholeNormalizedBox.
    func beginTracking(pixelBuffer: CVPixelBuffer) {
        isReadyToBegin = false
        sequenceHandler = VNSequenceRequestHandler()   // fresh session
        let observation = VNDetectedObjectObservation(boundingBox: peepholeNormalizedBox)
        currentObservation = observation
        isTracking = true
        trackedBounds = peepholeNormalizedBox
    }

    /// Runs the tracking request on a new frame and updates trackedBounds.
    func process(pixelBuffer: CVPixelBuffer) {
        guard isTracking, let observation = currentObservation else { return }
        let request = VNTrackObjectRequest(detectedObjectObservation: observation)
        request.trackingLevel = .accurate
        do {
            try sequenceHandler.perform([request], on: pixelBuffer, orientation: .right)
            guard let result = request.results?.first as? VNDetectedObjectObservation,
                  result.confidence > 0.1 else {
                Task { @MainActor in self.stopTracking() }
                return
            }
            currentObservation = result
            let bounds = result.boundingBox
            Task { @MainActor in self.trackedBounds = bounds }
        } catch {
            Task { @MainActor in self.stopTracking() }
        }
    }
}
