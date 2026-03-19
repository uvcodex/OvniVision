//
//  CameraControls.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI

struct CameraOverlayView: View {
    @Environment(\.dismiss) var dismiss
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
        GeometryReader { screen in
            ZStack {
                VStack {
                    CameraViewFinder(
                        size: Binding(
                            get: { cameraApi.viewFinderSize },
                            set: { cameraApi.viewFinderSize = $0 }
                        ),
                        filteredImage: cameraApi.viewFinderImage
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
                    // MARK: Compas -
                    GeometryReader { geo in
                        CameraCompassView(
                            compassApi: cameraApi.compassApi,
                            width: geo.size.width
                        )
                    }
                    .padding(.top, 6)
                    HStack {
                        Spacer()
                        MapThumbNail()
                    }
                    
                    Spacer()
                    
                    // MARK: Lense picker -
                    ZStack {
                        CameraLensesView(lenses: lenses, activeLens: activeLens) { lens in
                            cameraApi.switchLens(to: lens)
                        }
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(.white.opacity(0.5))
                                
                                Text("\(cameraApi.zoomPercentage)%")
                                    .font(.custom("JetBrainsMono-Regular", size: 16))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            
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
                        .padding(.horizontal, 12)
                    }
                    
                    // MARK: Controls -
                    CameraControls()
                }
            }
            .onChange(of: cameraApi.trackApi.trackedBounds) { _, bounds in
                guard cameraApi.trackApi.isTracking, let bounds else { return }
                let mid = cameraApi.viewFinderCenter
                let naturalX = mid.x - viewFinderPosition.width
                let naturalY = mid.y - viewFinderPosition.height
                let targetX = bounds.midX * screen.size.width
                let targetY = (1 - bounds.midY) * screen.size.height
                viewFinderPosition.width  = targetX - naturalX
                viewFinderPosition.height = targetY - naturalY
            }
        }
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "xmark")
//                        .frame(width: 10, height: 10)
//                        .frame(width: 30, height: 30)
//                }
//                .tint(.red)
//            }
//        }
    }
    
}

#Preview {
    let cameraApi: MockCameraRepository = {
        let mock = MockCameraRepository.shared
        mock.initialize()
        return mock
    }()
    
    NavigationStack {
        CameraOverlayView()
            .environment(cameraApi)
    }
    
}
