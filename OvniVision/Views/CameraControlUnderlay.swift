//
//  CameraControlUnderlay.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI

struct CameraControlUnderlay: View {
    var height: CGFloat = 140
    @Environment(CameraRepository.self) var cameraApi
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                
                Rectangle()
                    .frame(width: 65, height: 65)
                    .foregroundStyle(.clear)
                
                Spacer()
                
                // MARK: Cycle filters button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        cameraApi.cycleFilter()
                    }
                } label: {
                    Image(systemName: "camera.filters")
                        .symbolRenderingMode(.hierarchical)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .frame(width: 65, height: 65)
                }
                .foregroundStyle(.blue)
                .glassEffect(.regular.tint(.indigo.opacity(0.2)).interactive())
                
                Spacer()
            }
            
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
        .frame(height: height)
        
    }
}

#Preview {
    @Previewable @State var cameraApi: MockCameraRepository = {
        let mock = MockCameraRepository.shared
        mock.initialize()
        return mock
    }()
    CameraControlUnderlay()
        .environment(cameraApi)
}
