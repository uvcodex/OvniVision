//
//  PlayBackScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import AVKit
import SwiftUI

struct PlaybackScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(VideosRepository.self) var videosApi
    @State var playerApi: PlaybackRepository
    @State private var showDeleteAlert = false
    let video: AppVideo
    
    init(video: AppVideo) {
        self.video = video
        let playerApi = PlaybackRepository(file: video.fileURL)
        self._playerApi = State(initialValue: playerApi)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if playerApi.isLoading {
                    ProgressView()
                } else {
                    VideoPlayer(player: playerApi.player)
                }
                
            }
            .toolbar {
                // MARK: Dismiss button -
                ToolbarItem(placement:.cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.red)
                    }
                    .frame(width: 35, height: 35)
                }
                
                // MARK: Delete button -
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        playerApi.pause()
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.red)
                    }
                    .frame(width: 35, height: 35)
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
            .onAppear {
                playerApi.load(video)
                playerApi.play()
            }
            .onDisappear {
                playerApi.stop()
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
