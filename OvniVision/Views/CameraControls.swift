//
//  CameraControls.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI

struct CameraControls: View {
    @Environment(\.dismiss)  var dismiss
    @Environment(CameraRepository.self) var cameraApi
    @State private var viewFinderPosition: CGSize = .zero
    @State private var viewFinderDrag: CGSize = .zero
    
    private var lenses: [CameraLens] {
        cameraApi.availableLenses
    }
    private var activeLens: CameraLens? {
        cameraApi.activeLens
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                CameraViewFinder(
                    size: Binding(
                        get: { cameraApi.viewFinderSize },
                        set: { cameraApi.viewFinderSize = $0 }
                    ),
                    filteredImage: cameraApi.processedImages ?? nil
                )
            }
            .offset(
                x: viewFinderPosition.width + viewFinderDrag.width,
                y: viewFinderPosition.height + viewFinderDrag.height
            )
            .gesture(
                DragGesture()
                    .onChanged { viewFinderDrag = $0.translation }
                    .onEnded {
                        viewFinderPosition.width += $0.translation.width
                        viewFinderPosition.height += $0.translation.height
                        viewFinderDrag = .zero
                    }
            )
            VStack {
                GeometryReader { geo in
                    CameraCompassView(width: geo.size.width)
                }
                .frame(height: 70)
                .padding(.top, 8)
                Spacer()
                CameraLensesView(lenses: lenses, activeLens: activeLens) { lens in
                    cameraApi.switchLens(to: lens)
                }
                CameraControlUnderlay(height: 100)
                    .ignoresSafeArea(edges: .bottom)
            }
            .ignoresSafeArea(edges: .bottom)
            .safeAreaBar(edge: .top) {
                HStack {
                    Button {
                        dismiss()
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
    
}

#Preview {
    let cameraApi: MockCameraRepository = {
        let mock = MockCameraRepository.shared
        mock.initialize()
        return mock
    }()
    
    NavigationStack {
        CameraControls()
            .environment(cameraApi)
    }
    
}
