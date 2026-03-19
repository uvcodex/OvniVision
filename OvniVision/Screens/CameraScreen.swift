//
//  CameraScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct CameraScreen: View {
    @GestureState private var isPinching = false
    @Binding var isPresented: Bool
    @State private var baseZoom: CGFloat = 1.0
    @State var cameraApi = CameraRepository.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                CameraOverlayView()

                if !cameraApi.isReady {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                cameraApi.setupSession()
            }
            .onDisappear {
                cameraApi.trackApi.stopTracking()
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
    .environment(CompassRepository())
}
