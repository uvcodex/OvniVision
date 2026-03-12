//
//  CameraScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct CameraScreen: View {
    @Binding var isPresented: Bool
    @State private var baseZoom: CGFloat = 1.0
    @GestureState private var isPinching = false
    
    var cameraApi = CameraRepository.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if cameraApi.isAuthorized {
                    CameraPreview(session: cameraApi.session)
                        .ignoresSafeArea()
                        .gesture(
                            MagnificationGesture()
                                .updating($isPinching) { _, state, _ in
                                    state = true
                                }
                                .onChanged { value in
                                    cameraApi.setZoom(baseZoom * value)
                                }
                                .onEnded { _ in
                                    baseZoom = cameraApi.zoomFactor
                                }
                        )
                        .onChange(of: cameraApi.zoomFactor) { _, newValue in
                            if !isPinching { baseZoom = newValue }
                        }
                    
                    CameraControls(
                        cameraApi: cameraApi,
                        isPresented: $isPresented
                    )
                } else {
                    CameraPermissionView(isPresented: $isPresented)
                }
            }
            .task {
                await cameraApi.requestPermissions()
            }
            .onDisappear {
                cameraApi.stopSession()
            }
        }
        .environment(cameraApi)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    NavigationStack {
        CameraScreen(isPresented: $isPresented)
    }
    .environment(CameraRepository.shared)
}
