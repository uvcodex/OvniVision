//
//  CameraRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import Foundation
import AVFoundation
import ObjectBox // Used for persisting VideoRecord to the local store
import CoreImage
import Vision

protocol CameraApi {
    var session: AVCaptureSession { get }
    var isAuthorized: Bool { get }
    var availableLenses: [CameraLens] { get }
    var activeLens: CameraLens? { get }
    var zoomFactor: CGFloat { get }
    var zoomPercentage: Int { get }
    var errorMessage: String? { get }
    
    // Recording state
    var recordingSate: RecordingState { get }
    var recordingDuration: TimeInterval { get }
    var isRecording: Bool { get }
    var isSaving: Bool { get }
    
    // Filter states
    var viewFinderImage: CGImage? { get }
    var processedImages: CGImage? { get }
    var activeFilter: VideoFilter? { get }

    // Detection
    var trackApi: TrackObjectRepository { get }
    var viewFinderCenter: CGPoint { get set }
    var viewFinderSize: CGFloat { get set }
    
    func requestPermissions() async
    func switchLens(to: CameraLens)
    func setZoom(_ factor: CGFloat)
    func stopSession()
    
    // Recording
    func startRecording()
    func stopRecording()
    func resetRecording()

    // Filters
    func cycleFilter()

}

// MARK: - CameraRepository

@Observable
final class CameraRepository: NSObject, CameraApi {
    private init(localApi: LocalStoreRepository = .shared) {
        self.localApi = localApi
        super.init()
    }
    static let shared = CameraRepository()
    
    private let localApi: LocalApi
    private let metadataApi = MetadataRepository.shared

    /// Set by CameraScreen so heading can be sampled during recording.
    var compassApi = CompassRepository()
    var trackApi = TrackObjectRepository()
    
    // MARK: - Session
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var captureDevice: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    
    private let ciContext = CIContext()
    private let sessionQueue = DispatchQueue(label: "com.ovni-vision.camera-session")
    private let videoSessionQueue = DispatchQueue(label: "com.ovni-vision.camera-session")
    
    // MARK: - State
    var isAuthorized = false
    var availableLenses: [CameraLens] = []
    var zoomFactor: CGFloat = 1.0
    var errorMessage: String?
    var activeLens: CameraLens?
    
    // MARK: - Recording state
    private var durationTimer: Timer?
    private var samplingTimer: Timer?
    private var recordingStartTime: Date?
    var recordingSate: RecordingState = .idle
    var recordingDuration: TimeInterval = 0
    var viewFinderSize: CGFloat = 150.0
    var viewFinderCenter: CGPoint = .zero
    var isRecording: Bool {
        recordingSate == .recording
    }
    var isSaving: Bool {
        recordingSate == .saving
    }
    
    // MARK: - Zoom percentage (0–100 across available lens range)
    var zoomPercentage: Int {
        let minZ = availableLenses.first?.zoomFactor ?? 1
        let maxZ = availableLenses.last?.zoomFactor ?? minZ
        guard maxZ > minZ else { return 100 }
        return max(0, min(100, Int(((zoomFactor - minZ) / (maxZ - minZ)) * 100)))
    }

    // MARK: - Image filter state
    var viewFinderImage: CGImage? = nil
    var processedImages: CGImage? = nil
    var activeFilter: VideoFilter? = nil

    // MARK: - Filter cycling
    func cycleFilter() {
        let filters: [VideoFilter] = [.noir, .colorInvert, .thermal]
        if let current = activeFilter, let idx = filters.firstIndex(of: current) {
            let next = idx + 1
            activeFilter = next < filters.count ? filters[next] : nil
        } else {
            activeFilter = filters.first
        }
        if activeFilter == nil {
            processedImages = nil
        }
    }
    
    
    // MARK: - Authorization
    func requestPermissions() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioPermission = AVAudioApplication.shared.recordPermission
        
        var videoGranted = videoStatus == .authorized
        var audioGranted = audioPermission == .granted
        
        Task {
            if videoStatus == .notDetermined {
                videoGranted = await AVCaptureDevice.requestAccess(for: .video)
            }
            if audioPermission == .undetermined {
                audioGranted = await withCheckedContinuation { continuation in
                    AVAudioApplication.requestRecordPermission { continuation.resume(returning: $0) }
                }
            }
            
            await MainActor.run {
                isAuthorized = videoGranted && audioGranted
                if !videoGranted {
                    errorMessage = "Camera access is required to record video."
                } else if !audioGranted {
                    errorMessage = "Microphone access is required to record video."
                }
                
                if isAuthorized {
                    sessionQueue.async { [weak self] in
                        guard let self else { return }
                        self.configureSession()
                    }
                }
            }
        }
    }
    
    private func configureSession() {
        guard let device = bestVirtualDevice() else { return }
        self.captureDevice = device
        
        let lenses = buildLenses(for: device)
        Task { @MainActor in
            self.availableLenses = lenses
            self.activeLens = lenses.first
            if let zoom = lenses.first?.zoomFactor {
                self.zoomFactor = zoom
            }
        }
        
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                Task {  @MainActor in
                    self.videoInput = videoInput
                }
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = error.localizedDescription
            }
            return
        }
        
        do {
            if let audio = AVCaptureDevice.default(for: .audio) {
                let audioInput = try AVCaptureDeviceInput(device: audio)
                if session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                    Task { @MainActor in
                        self.audioInput = audioInput
                    }
                }
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = error.localizedDescription
            }
        }
        
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
            if let connection = movieOutput.connection(with: .video),
               connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
        }
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoSessionQueue)
        }
        
        session.commitConfiguration()
        session.startRunning()
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
        let upperBound = availableLenses.last?.zoomFactor ?? device.maxAvailableVideoZoomFactor
        let clamped = max(device.minAvailableVideoZoomFactor, min(factor, upperBound))
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clamped
            device.unlockForConfiguration()
        } catch {
            return
        }
        
        zoomFactor = clamped
        activeLens = availableLenses.last(where: { $0.zoomFactor <= zoomFactor }) ?? availableLenses.first
    }
    
    // MARK: - Cleanup
    func stopSession() {
//        detectionRepo.stop()
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.stopRunning()
        }

        let defaultZoom = availableLenses.first(where: { $0.zoomFactor == 1.0 })
        let zoom = defaultZoom?.zoomFactor ?? availableLenses.first?.zoomFactor ?? 1.0
        
        Task { @MainActor in
            setZoom(zoom)
            activeLens = availableLenses.first(where: { $0.zoomFactor == zoom })
            viewFinderSize = 150.0
            activeFilter = nil
            processedImages = nil
            viewFinderImage = nil
        }
    }
    
    // MARK: - Recording
    func startRecording() {
        guard recordingSate == .idle else { return }
        
        let fileName = "\(UUID().uuidString).mov"
        let url = LocalStoreRepository.videosDirectory.appendingPathComponent(fileName)
        
        movieOutput.startRecording(to: url, recordingDelegate: self)
        recordingSate = .recording
    }
    
    func stopRecording() {
        guard isRecording else { return }
        recordingSate = .saving
        movieOutput.stopRecording()
        stopDurationTimer()
    }
    
    func resetRecording() {
        recordingSate = .idle
    }
    
    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
    
    // MARK: - Duration Timer
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let start = self.recordingStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(start)
        }
    }

    // MARK: - Compass Sampling Timer (15 fps)
    private func startSamplingTimer() {
        samplingTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 15.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.metadataApi.sample(
                heading: self.compassApi.heading,
                timeOffset: self.recordingDuration
            )
        }
    }

    private func stopSamplingTimer() {
        samplingTimer?.invalidate()
        samplingTimer = nil
    }

}

extension CameraRepository: AVCaptureFileOutputRecordingDelegate {
    // MARK: Start Capture delegates -
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, startPTS: CMTime, from connections: [AVCaptureConnection]) {
        Task { @MainActor in
            recordingStartTime = Date()
            metadataApi.reset()
            startDurationTimer()
            startSamplingTimer()
        }
    }
    
    // MARK: Stop Capture delegates -
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        if let error {
            Task { @MainActor in
                errorMessage = error.localizedDescription
                recordingSate = .idle
                recordingDuration = 0
                recordingStartTime = nil
            }
            stopSamplingTimer()
            try? FileManager.default.removeItem(at: outputFileURL)
            return
        }

        stopSamplingTimer()
        metadataApi.save(videoFileName: outputFileURL.lastPathComponent)

        let duration = recordingDuration
        let fileSize = (try? outputFileURL
            .resourceValues(forKeys: [.fileSizeKey]).fileSize)
            .map { Int64($0) } ?? 0

        let record = VideoRecord(
            fileName: outputFileURL.lastPathComponent,
            duration: duration,
            fileSize: fileSize
        )
        
        do {
            try localApi.store.box(for: VideoRecord.self).put(record)
        } catch {
            Task { @MainActor in
                errorMessage = "Failed to save recording: \(error.localizedDescription)"
            }
        }
        
        Task { @MainActor in
            recordingSate = .idle
            recordingDuration = 0
            recordingStartTime = nil
        }
    }
}


extension CameraRepository: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if trackApi.isReadyToBegin {
            trackApi.beginTracking(pixelBuffer: pixelBuffer)
        } else if trackApi.isTracking {
            trackApi.process(pixelBuffer: pixelBuffer)
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        if let filter = activeFilter,
           let filtered = filter.apply(to: ciImage),
           let cgImage = ciContext.createCGImage(filtered, from: filtered.extent) {
            Task { @MainActor in
                guard self.activeFilter != nil else { return }
                self.processedImages = cgImage
                self.viewFinderImage = cgImage
            }
        } else if let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) {
            Task { @MainActor in
                self.viewFinderImage = cgImage
            }
        }
    }
}

