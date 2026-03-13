//
//  PlaybackRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import AVKit
import Foundation

@Observable
final class PlaybackRepository {
    private var timeObserver: Any?

    init(file: URL) {
        self.player = AVPlayer(url: file)
//        Task {
//            let asset = AVURLAsset(url: file)
//            let tracks = try? await asset.loadTracks(withMediaType: .video)
//            let fps = try? await tracks?.first?.load(.nominalFrameRate)
//            let resolvedFps = Double(fps ?? 30)
//            let interval = CMTime(value: 1, timescale: CMTimeScale(resolvedFps))
//            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
//                let frame = Int(time.seconds * resolvedFps)
//                print("Frame: \(frame)")
//            }
//        }
    }

    var player: AVPlayer
    var isLoading: Bool = false
    private var isPlaying = false

    func load(_ video: AppVideo) {
        isLoading = true
        player = AVPlayer(url: video.fileURL)
        isLoading = false
    }

    func play() {
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func stop() {
        player.pause()
        player.seek(to: .zero)
        isPlaying = false
    }
}
