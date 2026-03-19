//
//  HomeScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct HomeScreen: View {
    @Environment(VideosRepository.self) var videosApi
    @State private var selectedVideo: AppVideo?

    private func durationLabel(_ seconds: Double) -> String {
        let t = Int(seconds)
        return String(format: "%d:%02d", t / 60, t % 60)
    }
    
    var body: some View {
        Group {
            if videosApi.videos.isEmpty {
                NoVideosScreen()
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                        ForEach(videosApi.videos) { video in
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
                                        Text(durationLabel(video.duration))
                                        Text(video.createdAt.formatted(.dateTime.month(.abbreviated).day().year()))
                                    }
                                    .font(.custom("JetBrainsMono-Regular", size: 10))
                                    .foregroundStyle(.white)
                                    .padding(5)
                                    .background(.ultraThinMaterial.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .padding(2)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .onTapGesture { selectedVideo = video }
                        }
                    }
                    .padding(.horizontal, 6)
                }
            }
        }
        .onAppear { videosApi.getVideos() }
        .fullScreenCover(item: $selectedVideo) { video in
            PlaybackScreen(video: video)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppLogo(width: 120)
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .appBackgroundGradient()
    }
}

#Preview {
    NavigationStack{
        HomeScreen()
    }
    .environment(VideosRepository.shared)
}
