
//
//  CameraRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import Foundation
import AVFoundation

// MARK: - CameraRepository

@Observable
final class MockCameraRepository: NSObject, CameraApi {
    static let shared = MockCameraRepository()
    
    private override init() {
        
    }
    
    // MARK: - Session
    let session = AVCaptureSession()
    
    // MARK: - State
    var isAuthorized = false
    var zoomFactor: CGFloat = 1.0
    var errorMessage: String?
    var activeLens: CameraLens?
    var availableLenses: [CameraLens] = [
        CameraLens(id: "ultrawide", type: .builtInUltraWideCamera, zoomFactor: 0.5),
        CameraLens(id: "wide", type: .builtInWideAngleCamera, zoomFactor: 1.0),
        CameraLens(id: "telephoto", type: .builtInTelephotoCamera, zoomFactor: 3.0)
    ]
    
    // MARK: - Recording state
    private var durationTimer: Timer?
    private var recordingStartTime: Date?
    var recordingSate: RecordingState = .idle
    var recordingDuration: TimeInterval = 0
    var isRecording: Bool {
        recordingSate == .recording
    }
    var isSaving: Bool {
        recordingSate == .saving
    }
    
    func initialize() {
        self.isAuthorized = true
        self.activeLens = availableLenses.first
    }
    
    func requestPermissions() async {
        
    }
    
    // MARK: - Lens switching
    func switchLens(to lens: CameraLens) {
        activeLens = availableLenses.first(where: { $0.id == lens.id })
    }
    
    // MARK: - Zoom
    @MainActor
    func setZoom(_ factor: CGFloat) {
        
    }
    
    // MARK: - Cleanup
    func stopSession() {
        
    }
    
    func startRecording() {
        guard recordingSate == .idle else { return }
        recordingSate = .recording
        recordingStartTime = Date()
        startDurationTimer()
    }
    
    func stopRecording() {
        guard isRecording else { return }
        stopDuration()
        recordingStartTime = nil
        recordingDuration = 0
        recordingSate = .saving
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(6))
            recordingSate = .idle
        }
    }
    
    func resetRecording() {
        recordingSate = .idle
    }
    
    // MARK: - Duration Timer
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let start = self.recordingStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(start)
        }
    }
    
    private func stopDuration() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
}
