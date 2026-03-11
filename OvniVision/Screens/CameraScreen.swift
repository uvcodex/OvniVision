//
//  CameraScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct CameraScreen: View {
    @Binding var isPresented: Bool
    var cameraApi = CameraRepository()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if cameraApi.isAuthorized {
                    // Live preview
                    CameraPreview(session: cameraApi.session)
                        .ignoresSafeArea()
                    CameraControls(isPresented: $isPresented)
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
    @Previewable let cameraApi = CameraRepository()
    @Previewable @State var isPresented = true
    
    NavigationStack {
        CameraScreen(isPresented: $isPresented)
    }
        .environment(cameraApi)
}
