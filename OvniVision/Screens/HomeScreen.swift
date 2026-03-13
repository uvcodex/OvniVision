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
    
    var body: some View {
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
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    .onTapGesture { selectedVideo = video }
                }
            }
            .padding(.horizontal, 6)
        }
        .onAppear { videosApi.getVideos() }
        .fullScreenCover(item: $selectedVideo) { video in
            PlaybackScreen(video: video)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppLogo(width: 90)
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
}

#Preview {
    NavigationStack{
        HomeScreen()
    }
    .environment(VideosRepository.shared)
}
