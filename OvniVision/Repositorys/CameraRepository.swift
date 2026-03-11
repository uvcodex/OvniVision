//
//  CameraRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import Foundation
import AVFoundation

//protocol CameraApi {
//    var isAuthorized: Bool { get }
//    var errorMessage: String? { get }
//    var session: AVCaptureSession { get }
//    
//    func requestPermissions() async
//    func stopSession()
//}


@Observable
final class CameraRepository: NSObject {
    // MARK: - Session
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    @ObservationIgnored private let captureSession = DispatchQueue(
        label: "com.ovni-vision.camera-session"
    )
    
    // MARK: - State
    var isAuthorized = false
    var currentLens: AVCaptureDevice.Position = .back
    var errorMessage: String?
    
    
    
    // MARK: - Authorization
    func requestPermissions() async {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        var videoGranted = videoStatus == .authorized
        var audioGranted = audioStatus == .authorized
        
        if videoStatus == .notDetermined {
            videoGranted = await AVCaptureDevice.requestAccess(for: .video)
        }
        if audioStatus == .notDetermined {
            audioGranted = await AVCaptureDevice.requestAccess(for: .audio)
        }
        
        await MainActor.run {
            isAuthorized = videoGranted && audioGranted
        }
        
        if isAuthorized {
            await setupSession()
        }
    }
    
    // MARK: - Session setup
    private func setupSession() async {
        captureSession.async { [weak self] in
            guard let self else { return }
            self.configureSession()
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        
        // Vido input
        if let lens = bestLens(for: self.currentLens) {
            do {
                let input = try AVCaptureDeviceInput(device: lens)
                if session.canAddInput(input) {
                    session.addInput(input)
                    self.videoInput = input
                }
                
            } catch {
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        // Audio input
        if let mic = AVCaptureDevice.default(for: .audio) {
            do {
                let input = try AVCaptureDeviceInput(device: mic)
                if session.canAddInput(input) {
                    session.addInput(input)
                    audioInput = input
                }
            } catch {
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        // Movie output
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
            if let  connection = movieOutput.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    private func bestLens(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualWideCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        return discovery.devices.first
    }
    
    // MARK: - Cleanup
    func stopSession() {
        captureSession.async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
}
