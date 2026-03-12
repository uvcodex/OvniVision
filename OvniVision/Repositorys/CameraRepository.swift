//
//  CameraRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import Foundation
import AVFoundation

protocol CameraApi {
    var session: AVCaptureSession { get }
    var isAuthorized: Bool { get }
    var availableLenses: [CameraLens] { get }
    var activeLens: CameraLens? { get }
    var zoomFactor: CGFloat { get }
    var errorMessage: String? { get }
    
    // Recording state
    var recordingSate: RecordingState { get }
    var recordingDuration: TimeInterval { get }
    var isRecording: Bool { get }
    var isSaving: Bool { get }
    
    func requestPermissions() async
    func switchLens(to: CameraLens)
    func setZoom(_ factor: CGFloat)
    func stopSession()
    
    // Recording
    func startRecording()
    func stopRecording()
    func resetRecording()
    
}

// MARK: - CameraRepository

@Observable
final class CameraRepository: NSObject, CameraApi {
    
    
    static let shared = CameraRepository()
    private override init() { }
    
    // MARK: - Session
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var captureDevice: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    @ObservationIgnored private let sessionQueue = DispatchQueue(
        label: "com.ovni-vision.camera-session"
    )
    
    // MARK: - State
    var isAuthorized = false
    var availableLenses: [CameraLens] = []
    var zoomFactor: CGFloat = 1.0
    var errorMessage: String?
    var activeLens: CameraLens?
    
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
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureSession()
        }
    }
    
    private func configureSession() {
        guard let device = bestVirtualDevice() else { return }
        captureDevice = device
        
        let lenses = buildLenses(for: device)
        let defaultLens = lenses.first(where: { $0.zoomFactor == 1.0 }) ?? lenses.first
        
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                videoInput = input
            }
        } catch {
            Task { @MainActor in self.errorMessage = error.localizedDescription }
        }
        
        if let mic = AVCaptureDevice.default(for: .audio) {
            do {
                let input = try AVCaptureDeviceInput(device: mic)
                if session.canAddInput(input) {
                    session.addInput(input)
                    audioInput = input
                }
            } catch {
                Task { @MainActor in self.errorMessage = error.localizedDescription }
            }
        }
        
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
            if let connection = movieOutput.connection(with: .video),
               connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
        }
        
        session.commitConfiguration()
        session.startRunning()
        
        Task { @MainActor in
            self.availableLenses = lenses
            self.activeLens = defaultLens
            if let z = defaultLens?.zoomFactor { self.zoomFactor = z }
        }
    }
    
    // MARK: - Virtual device selection
    /// Returns the virtual device that manages the most physical back cameras.
    private func bestVirtualDevice() -> AVCaptureDevice? {
        let types: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .back
        )
        return discovery.devices.max { $0.constituentDevices.count < $1.constituentDevices.count }
    }
    
    // MARK: - Lens button construction
    private func buildLenses(for device: AVCaptureDevice) -> [CameraLens] {
        let switchOvers = device.virtualDeviceSwitchOverVideoZoomFactors.map { CGFloat(truncating: $0) }
        let minZoom = device.minAvailableVideoZoomFactor
        let zoomFactors = [minZoom] + switchOvers
        
        let physicalOrder: [AVCaptureDevice.DeviceType] = [
            .builtInUltraWideCamera,
            .builtInWideAngleCamera,
            .builtInTelephotoCamera
        ]
        let sorted = device.constituentDevices.sorted {
            (physicalOrder.firstIndex(of: $0.deviceType) ?? 99) < (physicalOrder.firstIndex(of: $1.deviceType) ?? 99)
        }
        
        return sorted.enumerated().compactMap { index, physical in
            guard index < zoomFactors.count else { return nil }
            return CameraLens(
                id: physical.uniqueID,
                type: physical.deviceType,
                zoomFactor: zoomFactors[index]
            )
        }
    }
    
    // MARK: - Lens switching
    func switchLens(to lens: CameraLens) {
        setZoom(lens.zoomFactor)
    }
    
    // MARK: - Zoom
    @MainActor
    func setZoom(_ factor: CGFloat) {
        guard let device = captureDevice else { return }
        let clamped = max(
            device.minAvailableVideoZoomFactor, min(factor, device.maxAvailableVideoZoomFactor)
        )
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clamped
            device.unlockForConfiguration()
        } catch { return }
        
        zoomFactor = clamped
        activeLens = availableLenses.last(where: { $0.zoomFactor <= zoomFactor }) ?? availableLenses.first
    }
    
    // MARK: - Cleanup
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    // MARK: - Recording
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
