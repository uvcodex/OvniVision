//
//  HomeScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct HomeScreen: View {
    @Environment(VideosRepository.self) var videosApi
    @Environment(LocationRepository.self) var locationApi
    @State var isCameraPresented: Bool = false
    @State var isSettingsPresented: Bool = false
    @State private var selectedVideo: AppVideo?
    
    private func durationLabel(_ seconds: Double) -> String {
        let t = Int(seconds)
        return String(format: "%d:%02d", t / 60, t % 60)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if videosApi.videos.isEmpty {
                    NoVideosScreen()
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                            ForEach(videosApi.videos) { video in
                                VideoThumbnailCell(
                                    video: video,
                                    durationLabel: durationLabel(video.duration)
                                )
                                .onTapGesture { selectedVideo = video }
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    .fullScreenCover(item: $selectedVideo) { video in
                        PlaybackScreen(video: video)
                    }
                }
            }
            .appBackgroundGradient()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AppLogo(width: 140)
                }
                .sharedBackgroundVisibility(.hidden)
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSettingsPresented.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .safeAreaBar(edge: .bottom) {
                HStack {
                    Spacer()
                    PermissionButton {
                        isCameraPresented = true
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            videosApi.getVideos()
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraScreen(isPresented: $isCameraPresented)
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsScreen(isPresented: $isSettingsPresented)
                .presentationDetents([.medium])
        }
        .onChange(of: isCameraPresented) { _, isPresented in
            if !isPresented {
                locationApi.stop()
                videosApi.getVideos()
            }
        }
    }
}

private struct VideoThumbnailCell: View {
    let video: AppVideo
    let durationLabel: String
    
    var body: some View {
        let dateLabel = video.createdAt.formatted(
            .dateTime.month(.abbreviated).day().year()
        )
        
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let thumbnail = video.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray
                }
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(durationLabel)
                    Text(dateLabel)
                }
                .font(.custom("JetBrainsMono-Regular", size: 10))
                .foregroundStyle(.white)
                .padding(5)
                .background(.ultraThinMaterial.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

#Preview {
    NavigationStack{
        HomeScreen()
    }
    .environment(VideosRepository.shared)
}
