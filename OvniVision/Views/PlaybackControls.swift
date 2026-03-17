//
//  PlaybackControlls.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/17/26.
//

import SwiftUI

struct PlaybackControls<Content: View>: View {
    init(
        videosApi: VideosApi,
        playerApi: PlayerApi,
        video: AppVideo,
        height: CGFloat = 90,
        @ViewBuilder content: () -> Content
    ) {
        self.videosApi = videosApi
        self.playerApi = playerApi
        self.video = video
        self.height = height
        self.content = content()
    }
    
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    var videosApi: VideosApi
    var playerApi: PlayerApi
    let video: AppVideo
    var height: CGFloat
    var content: Content
    
    
    var body: some View {
        VStack {
            content
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
        }
        .onDisappear {
            playerApi.stop()
        }
        .toolbar {
            // MARK: Dismiss button -
            ToolbarItem(placement:.cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 13, height: 13)
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
        .safeAreaBar(edge: .bottom) {
            VStack {
                Slider(
                    value: Binding(
                        get: { playerApi.currentTime },
                        set: { playerApi.seekTo($0) }
                    ),
                    in: 0...max(playerApi.duration, 1)
                )
                .tint(.orange.opacity(0.8))
                .padding(.horizontal, 85)
                
                ZStack {
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                
                            }
                        } label: {
                            // MARK: Tack Button
                            Image(systemName: "ellipsis.viewfinder")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white.opacity(0.8))
                            
                        }
                        .frame(width: 45, height: 45)
                        .glassEffect(.regular, in: Circle())
                        
                        // Seek back button
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                playerApi.seek(by: -15)
                            }
                        } label: {
                            Image(systemName: "gobackward.15")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(width: 45, height: 45)
                        .glassEffect(.regular, in: Circle())
                        
                        
                        
                        Rectangle()
                            .frame(width: 65, height: 65)
                            .foregroundStyle(.clear)
                        
                        // Seek forward 15
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                playerApi.seek(by: 15)
                            }
                        } label: {
                            Image(systemName: "goforward.15")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white.opacity(0.8))
                            
                        }
                        .frame(width: 45, height: 45)
                        .glassEffect(.regular, in: Circle())
                        
                        // Apply filters/cycle filters
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                
                            }
                        } label: {
                            Image(systemName: "camera.filters")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(width: 45, height: 45)
                        .glassEffect(.regular, in: Circle())
                    }
                    
                    // MARK: Play/Pause -
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                playerApi.togglePlayPause()
                            }
                        } label: {
                            Image(systemName: playerApi.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .offset(x: playerApi.isPlaying ? 0 : 2)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(width: 55, height: 55)
                        .glassEffect(.regular, in: Circle())
                    }
                }
            }
            .frame(height: height)
        }
        
    }
}

#Preview {
    //    PlaybackControls()
}
