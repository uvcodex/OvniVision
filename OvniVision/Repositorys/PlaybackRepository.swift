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
    
    func load(_ video: AppVideo)
    func pause()
    func stop()
    func togglePlayPause()
    func seek(by seconds: Double)
    func seekTo(_ seconds: Double)
}

@Observable
final class PlayerRepository: PlayerApi {
    init(file: URL) {
        self.player = AVPlayer(url: file)
    }
    
    var player: AVPlayer
    var isPlaying = false
    var duration: Double = 0
    var currentTime: Double = 0
    var isLoading: Bool = false
    
    private var timeObserver: Any?

    func load(_ video: AppVideo) {
        isLoading = true
        let item = AVPlayerItem(url: video.fileURL)
        player = AVPlayer(playerItem: item)
        if let observer = timeObserver { player.removeTimeObserver(observer) }
        let interval = CMTimeMakeWithSeconds(0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            if let d = self?.player.currentItem?.duration.seconds, d.isFinite {
                self?.duration = d
            }
        }
        isLoading = false
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
    }
}
