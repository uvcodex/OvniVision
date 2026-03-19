//
//  CameraControlUnderlay.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI

struct CameraControls: View {
    @Environment(\.dismiss)  var dismiss
    @Environment(CameraRepository.self) var cameraApi
    
    var body: some View {
        ZStack {
            HStack {
                CameraButton(icon: "xmark", iconSize: 15, color: .red) {
                    dismiss()
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            
            HStack {
                Spacer()

                // MARK: Tracking button -
                CameraButton(icon: "dot.viewfinder", iconSize: 20, color: .orange, effect: true) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if cameraApi.trackApi.isTracking || cameraApi.trackApi.isReadyToBegin {
                            cameraApi.trackApi.stopTracking()
                        } else {
                            cameraApi.trackApi.requestStart()
                        }
                    }
                }
                
                // MARK: Center spacing under record -
                Rectangle()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.clear)
                
                // MARK: Cycle filters button -
                CameraButton(icon: "camera.filters", color: .indigo) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        cameraApi.cycleFilter()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // MARK: Record button -
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if cameraApi.isRecording {
                            cameraApi.stopRecording()
                        } else {
                            cameraApi.startRecording()
                        }
                    }
                } label: {
                    
                    // MARK: Record button
                    ZStack {
                        // Outer ring
                        Circle()
                            .stroke(.gray.opacity(0.5), lineWidth: 1)
                            .fill(.ultraThinMaterial)
                            .frame(width: 65, height: 65)
                        
                        // Inner shape morphs between circle and rounded rect
                        if cameraApi.isRecording {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.red.opacity(0.9))
                                .frame(width: 35, height: 35)
                        } else {
                            Circle()
                                .fill(.red)
                                .fill(.red.opacity(0.5))
                                .frame(width: 55, height: 55)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
        }
    }
}

#Preview {
    @Previewable @State var cameraApi: MockCameraRepository = {
        let mock = MockCameraRepository.shared
        mock.initialize()
        return mock
    }()
    CameraControls()
        .environment(cameraApi)
}
