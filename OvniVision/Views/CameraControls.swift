//
//  CameraControls.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI

struct CameraControls: View {
    init(cameraApi: CameraApi, isPresented: Binding<Bool>) {
        self.cameraApi = cameraApi
        self._isPresented = isPresented
    }
    
    @Binding var isPresented: Bool
    private let cameraApi: CameraApi
    private var lenses: [CameraLens] {
        cameraApi.availableLenses
    }
    private var activeLens: CameraLens? {
        cameraApi.activeLens
    }
    
    var body: some View {
        
        VStack {
            Spacer()
            CameraLensesView(lenses: lenses, activeLens: activeLens) { lens in
                cameraApi.switchLens(to: lens)
            }
            CameraControlUnderlay(height: 100) {
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
                        // MARK: Cycle filters button
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                print("Cycle Filters")
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
                    
                    // MARK: Start Tracking button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            print("Start tracking")
                        }
                    } label: {
                        Image(systemName: "dot.viewfinder")
                            .symbolRenderingMode(.hierarchical)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .frame(width: 65, height: 65)
                    }
                    .foregroundStyle(.orange)
                    .glassEffect(.regular.tint(.yellow.opacity(0.2)).interactive())
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(edges: .bottom)
        .safeAreaBar(edge: .top) {
            HStack {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "chevron.down")
                        .frame(width: 45, height: 45)
                        .offset(y: 1)
                }
                .foregroundStyle(.red)
                .glassEffect(.regular.tint(.red.opacity(0.2)).interactive())
                Spacer()
                
                if cameraApi.isSaving {
                    CameraSavingPill()
                } else {
                    CameraRecordingBadge(
                        duration: cameraApi.recordingDuration,
                        isRecording: cameraApi.isRecording
                    )
                }
                
            }
            .padding(.horizontal, 16)
            
        }
    }
    
}

#Preview {
    let cameraApi: MockCameraRepository = {
        let mock = MockCameraRepository.shared
        mock.initialize()
        return mock
    }()
    
    NavigationStack {
        CameraControls(
            cameraApi: cameraApi,
            isPresented: .constant(true)
        )
    }
}
