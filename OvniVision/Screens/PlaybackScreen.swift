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
    init(video: AppVideo) {
        self.video = video
        let playerApi = PlayerRepository(file: video.fileURL)
        self._playerApi = State(initialValue: playerApi)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(VideosRepository.self) var videosApi
    @State var playerApi: PlayerApi
    @State var trackApi = TrackObjectRepository()
    @State var compassPlayback = PlaybackCompassRepository()
    let video: AppVideo

    var body: some View {
        NavigationStack {
            PlaybackControls(videosApi: videosApi, playerApi: playerApi, video: video, trackApi: trackApi) {
                ZStack {
                    ZStack {
                        AVPlayerControllerRepresented(player: playerApi.player)
                            .ignoresSafeArea()

                        PlaybackViewFinder(
                            filteredImage: playerApi.filteredImage,
                            activeFilter: playerApi.activeFilter,
                            trackApi: trackApi
                        )
                    }.ignoresSafeArea()

                    if compassPlayback.hasData {
                        VStack {
                            GeometryReader { geo in
                                PlaybackCompassView(width: geo.size.width, compassApi: compassPlayback)
                            }
                            .frame(height: 50)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
                
            }
        }
        .onAppear {
            playerApi.trackApi = trackApi
            compassPlayback.load(videoFileName: video.name)
            compassPlayback.update(currentTime: playerApi.currentTime)
        }
        .onChange(of: playerApi.currentTime) { _, time in
            compassPlayback.update(currentTime: time)
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
