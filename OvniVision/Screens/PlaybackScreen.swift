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
        vc.allowsVideoFrameAnalysis = false
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

struct PlaybackScreen: View {
    init(video: AppVideo) {
        self.video = video
        let playerApi = PlayerRepository(file: video.fileURL, duration: video.duration)
        self._playerApi = State(initialValue: playerApi)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(VideosRepository.self) var videosApi
    @State var playerApi: PlayerApi
    @State var trackApi = TrackObjectRepository()
    @State var compassPlayback = PlaybackCompassRepository()
    @State private var showDeleteAlert = false
    @State private var showClassTypes = false
    @State private var pendingAction: PlaybackAction? = nil
    let video: AppVideo
    
    enum PlaybackAction: Equatable { case classTypes, delete }
    
    private func timeLabel(_ seconds: Double) -> String {
        let s = max(0, seconds)
        let mins = Int(s) / 60
        let secs = Int(s) % 60
        let tenths = Int(s * 10) % 10
        return String(format: "%02d:%02d.%d", mins, secs, tenths)
    }
    
    private func durationLabel(_ seconds: Double) -> String {
        let s = max(0, seconds)
        return String(format: "%02d:%02d", Int(s) / 60, Int(s) % 60)
    }
    
    var body: some View {
        NavigationStack {
            PlaybackControls(videosApi: videosApi, playerApi: playerApi, video: video, trackApi: trackApi) {
                ZStack {
                    ZStack {
                        AVPlayerControllerRepresented(player: playerApi.player)
                            .ignoresSafeArea()
                        
                        PlaybackViewFinder(
                            filteredImage: playerApi.viewFinderImage,
                            activeFilter: playerApi.activeFilter,
                            trackApi: trackApi,
                            compassApi: compassPlayback
                        )
                    }
                    .ignoresSafeArea()
                    
                    if compassPlayback.hasData {
                        VStack {
                            PlaybackCompassView(compassApi: compassPlayback)
                            Spacer()
                            
                            HStack(alignment: .bottom) {
                                Text(timeLabel(playerApi.currentTime) + " / " + durationLabel(playerApi.duration))
                                    .font(.custom("JetBrainsMono-Regular", size: 12))
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Spacer()
                                if compassPlayback.hasLocation {
                                    MapPlaybackThumbNail(compassApi: compassPlayback)
                                }
                            }
                            .padding(12)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .offset(y: -1)
                            .foregroundStyle(.red)
                    }
                    .frame(width: 35, height: 35)
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    
                    Button {
                        showDeleteAlert.toggle()
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .tint(.red)
                    .frame(width: 35, height: 35)
                }
                
                ToolbarSpacer(.flexible, placement: .primaryAction)
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        showClassTypes.toggle()
                    } label: {
                        Image(systemName: "list.dash.header.rectangle")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .frame(width: 35, height: 35)
                    
                }
            }
            .onChange(of: pendingAction) { _, action in
                guard let action else { return }
                pendingAction = nil
                switch action {
                case .classTypes:
                    showClassTypes = true
                case .delete:
                    playerApi.pause()
                    showDeleteAlert = true
                }
            }
            .alert("Delete Video", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    videosApi.deleteVideo(video)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
            .sheet(isPresented: $showClassTypes) {
                VideoClassificationSheet(video: video)
                    .presentationDetents([.medium])
                    .environment(videosApi)
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
        duration: 0,
        thumbnail: nil,
        fileURL: URL(fileURLWithPath: ""),
        classifications: []
    )
    
    PlaybackScreen(video: mockVideo)
        .environment(VideosRepository.shared)
}
