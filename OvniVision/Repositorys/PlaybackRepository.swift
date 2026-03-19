//
//  PlaybackRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import AVKit
import CoreImage
import Foundation

protocol PlayerApi {
    var player: AVPlayer { get }

    var isLoading: Bool { get }
    var isPlaying: Bool { get }
    var currentTime: Double { get }
    var duration: Double { get }

    // Filter states
    var viewFinderImage: CGImage? { get }
    var filteredImage: CGImage? { get }
    var activeFilter: VideoFilter? { get }

    // Tracking
    var trackApi: TrackObjectRepository? { get set }

    func load(_ video: AppVideo)
    func pause()
    func stop()
    func togglePlayPause()
    func seek(by seconds: Double)
    func seekTo(_ seconds: Double)
    func cycleFilter()
}

@Observable
final class PlayerRepository: PlayerApi {
    init(file: URL, duration: Double) {
        self.player = AVPlayer(url: file)
        self.duration = duration
    }

    var player: AVPlayer
    var isPlaying = false
    var duration: Double = 0
    var currentTime: Double = 0
    var isLoading: Bool = false

    // Filter states
    var viewFinderImage: CGImage? = nil
    var filteredImage: CGImage? = nil
    var activeFilter: VideoFilter? = nil

    // Tracking
    var trackApi: TrackObjectRepository? = nil

    private var timeObserver: Any?
    private var endObserver: Any?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var displayTimer: Timer?
    private let ciContext = CIContext()
    private let processingQueue = DispatchQueue(label: "com.ovni-vision.playback-filter")

    func load(_ video: AppVideo) {
        isLoading = true
        let item = AVPlayerItem(url: video.fileURL)
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ])
        item.add(output)
        videoOutput = output
        player = AVPlayer(playerItem: item)
        if let observer = timeObserver { player.removeTimeObserver(observer) }
        if let observer = endObserver { NotificationCenter.default.removeObserver(observer) }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.isPlaying = false
        }
        let interval = CMTimeMakeWithSeconds(0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            if let d = self?.player.currentItem?.duration.seconds, d.isFinite {
                self?.duration = d
            }
        }
        // Always keep the display timer running; processCurrentFrame guards itself
        startDisplayTimer()
        isLoading = false
    }

    func cycleFilter() {
        let filters: [VideoFilter] = [.noir, .colorInvert, .thermal]
        if let current = activeFilter, let idx = filters.firstIndex(of: current) {
            let next = idx + 1
            activeFilter = next < filters.count ? filters[next] : nil
        } else {
            activeFilter = filters.first
        }
        if activeFilter == nil {
            filteredImage = nil
        } else {
            // Render immediately so the filter is visible even when paused
            processingQueue.async { [weak self] in self?.processCurrentFrame() }
        }
    }

    private func startDisplayTimer() {
        guard displayTimer == nil else { return }
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.processingQueue.async { self?.processCurrentFrame() }
        }
    }

    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }

    private func processCurrentFrame() {
        guard let output = videoOutput else { return }
        let time = player.currentTime()
        guard let pixelBuffer = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return }

        // Tracking
        if let trackApi {
            if trackApi.isReadyToBegin {
                trackApi.beginTracking(pixelBuffer: pixelBuffer)
            } else if trackApi.isTracking {
                trackApi.process(pixelBuffer: pixelBuffer)
            }
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        if let filter = activeFilter,
           let filtered = filter.apply(to: ciImage),
           let cgImage = ciContext.createCGImage(filtered, from: filtered.extent) {
            Task { @MainActor in
                self.filteredImage = cgImage
                self.viewFinderImage = cgImage
            }
        } else if let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) {
            Task { @MainActor in self.viewFinderImage = cgImage }
        }
    }

    func seekTo(_ seconds: Double) {
        let target = CMTimeMakeWithSeconds(seconds, preferredTimescale: 600)
        player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func play() {
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func seek(by seconds: Double) {
        let current = player.currentTime()
        let offset = CMTimeMakeWithSeconds(seconds, preferredTimescale: 600)
        let target = CMTimeAdd(current, offset)
        player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func stop() {
        player.pause()
        player.seek(to: .zero)
        isPlaying = false
        stopDisplayTimer()
        activeFilter = nil
        filteredImage = nil
        viewFinderImage = nil
        trackApi?.stopTracking()
    }
}
