//
//  NavigationInjector.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct AppNavigation<Content: View>: View {
    @Environment(VideosRepository.self) var videosApi
    @Environment(LocationRepository.self) var locationApi
    @ViewBuilder var content: Content
    @State var isCameraPresented: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                content
            }
            .safeAreaBar(edge: .bottom) {
                HStack {
                    Spacer()
                    PermissionButton {
                        isCameraPresented = true
                    }
                }
                .padding(.horizontal, 16)
                .fullScreenCover(isPresented: $isCameraPresented) {
                    CameraScreen(isPresented: $isCameraPresented)
                }
                .onChange(of: isCameraPresented) { _, isPresented in
                    if !isPresented {
                        locationApi.stop()
                        videosApi.getVideos()
                    }
                }
            }
        }
    }
}

#Preview {
//    @Previewable @State var isCameraPresented = false
//    AppNavigation() {
//        Spacer()
//    }
}
