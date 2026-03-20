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
    @State private var screenSize: CGSize = .zero
    private var lenses: [CameraLens] {
        cameraApi.availableLenses
    }
    private var activeLens: CameraLens? {
        cameraApi.activeLens
    }
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                CameraViewFinder(
                    size: Binding(
                        get: { cameraApi.viewFinderSize },
                        set: { cameraApi.viewFinderSize = $0 }
                    ),
                    filteredImage: cameraApi.viewFinderImage
                )
                
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
                
                VStack(spacing: 0) {
                    // MARK: Compass -
                    CameraCompassView(compassApi: cameraApi.compassApi)

                    Spacer()
                    HStack {
                        Spacer()
                        MapThumbNail()
                    }
    
                    
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
                let targetX = bounds.midX * screenSize.width
                let targetY = (1 - bounds.midY) * screenSize.height
                viewFinderPosition.width  = targetX - naturalX
                viewFinderPosition.height = targetY - naturalY
            }
            .onAppear {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                screenSize = scene.screen.bounds.size
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
        CameraOverlayView()
            .environment(cameraApi)
    }
    
}
