//
//  NavigationInjector.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct AppNavigation<Content: View>: View {
    @Environment(VideosRepository.self) var videosApi
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
                    Button {
                        isCameraPresented = true
                    } label: {
                        Image(systemName: "dot.viewfinder")
                            .symbolRenderingMode(.hierarchical)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .frame(width: 60, height: 60)
                    }
                    .foregroundStyle(.pink)
                    .glassEffect(.regular.tint(.red.opacity(0.3)).interactive())
                }
                .padding(.horizontal, 16)
                .fullScreenCover(isPresented: $isCameraPresented) {
                    CameraScreen(isPresented: $isCameraPresented)
                }
                .onChange(of: isCameraPresented) { _, isPresented in
                    if !isPresented { videosApi.getVideos() }
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
