//
//  PlayBackScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import AVKit
import SwiftUI
import UIKit

private struct AVPlayerControllerRepresented: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = false
        vc.videoGravity = .resizeAspectFill
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

struct PlaybackScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(VideosRepository.self) var videosApi
    @State var playerApi: PlayerApi
//        @State private var trackingApi = TrackObjectRepository() // VNDetectedObjectObservation
    
    
    let video: AppVideo
    
    init(video: AppVideo) {
        self.video = video
        let playerApi = PlayerRepository(file: video.fileURL)
        self._playerApi = State(initialValue: playerApi)
    }
    
    var body: some View {
        NavigationStack {
            PlaybackControls(videosApi: videosApi, playerApi: playerApi, video: video) {
                AVPlayerControllerRepresented(player: playerApi.player)
                    .ignoresSafeArea()
            }
        }
    }
    
}
#Preview {
    @Previewable let videosApi = VideosRepository.shared
    let mockVideo = AppVideo(
        id: 1,
        name: "Preview",
        createdAt: Date(),
        thumbnail: nil,
        fileURL: URL(fileURLWithPath: "")
    )
    
    PlaybackScreen(video: mockVideo)
        .environment(VideosRepository.shared)
}
