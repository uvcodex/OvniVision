//
//  CameraViewFinder.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/13/26.
//

import SwiftUI


struct CameraViewFinder: View {
    @Environment(CameraRepository.self) var cameraApi
    
    @Binding var size: CGFloat
    @State private var screenSize: CGSize = .zero
    @State private var dragStartSize: CGFloat = 0
    
    var filteredImage: CGImage? = nil
    private let minSize: CGFloat = 150
    private let maxSize: CGFloat = 350
    private let handleSize: CGFloat = 15
    private let previewZoom: CGFloat = 1.2
    
    var compassApi : CompassApi {
        cameraApi.compassApi
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.ultraThinMaterial.opacity(0.5))
                    .stroke(.white.opacity(0.3), lineWidth: 0.3)
                    .frame(width: size, height: size)
                
                if let cgImage = filteredImage {
                    GeometryReader { geo in
                        let globalFrame = geo.frame(in: .global)
                        let zoom = previewZoom * cameraApi.zoomFactor
                        Image(uiImage: UIImage(cgImage: cgImage, scale: 1, orientation: .right))
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenSize.width * zoom, height: screenSize.height * zoom)
                            .position(
                                x: size / 2 + zoom * (screenSize.width / 2 - globalFrame.midX),
                                y: size / 2 + zoom * (screenSize.height / 2 - globalFrame.midY)
                            )
                            .allowsHitTesting(false)
                    }
                    .clipped()
                }
                
                Image(systemName: "dot.viewfinder")
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.orange.opacity(0.9))
                
                // Corner handles
                ForEach([Corner.topLeft, .topRight, .bottomLeft, .bottomRight], id: \.self) { corner in
                    cornerHandle(corner)
                }
                
                VStack{
                    HStack {
                        Text("\(Int(compassApi.heading.rounded()))° \(cardinalLabel(compassApi.heading))")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(.orange)
                            .padding(.leading, 4)
                        
                        Spacer()
                        if let filterName = cameraApi.activeFilter?.displayName {
                            Text(filterName)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(6)
                    Spacer()
                }

            } // ZStack
            .frame(width: size, height: size)
            
        } // VStack
        .padding(.top, 70)
        .onAppear {
            dragStartSize = size
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            screenSize = scene.screen.bounds.size
        }
    }
    
    @ViewBuilder
    private func cornerHandle(_ corner: Corner) -> some View {
        Circle()
            .fill(.ultraThinMaterial.opacity(0.5))
            .frame(width: handleSize, height: handleSize)
            .offset(cornerOffset(for: corner))
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        let delta = corner.delta(from: value.translation)
                        size = min(maxSize, max(minSize, dragStartSize + delta))
                    }
                    .onEnded { value in
                        let delta = corner.delta(from: value.translation)
                        size = min(maxSize, max(minSize, dragStartSize + delta))
                        dragStartSize = size
                    }
            )
    }
    
    private func cardinalLabel(_ heading: Double) -> String {
        let dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return dirs[Int((heading + 22.5) / 45) % 8]
    }

    private func cornerOffset(for corner: Corner) -> CGSize {
        let half = size / 2
        switch corner {
        case .topLeft:     return CGSize(width: -half, height: -half)
        case .topRight:    return CGSize(width:  half, height: -half)
        case .bottomLeft:  return CGSize(width: -half, height:  half)
        case .bottomRight: return CGSize(width:  half, height:  half)
        }
    }
}

private enum Corner: CaseIterable, Hashable  {
    case topLeft, topRight, bottomLeft, bottomRight
    
    /// Sign to apply to drag translation so that pulling outward always increases size.
    var sign: CGFloat {
        switch self {
        case .bottomRight: return  1
        case .bottomLeft:  return -1   // x flipped
        case .topRight:    return  1   // y flipped below
        case .topLeft:     return -1
        }
    }
    
    /// Compute the 1-D delta that represents "grow / shrink" for this corner.
    func delta(from translation: CGSize) -> CGFloat {
        switch self {
        case .bottomRight: return ( translation.width + translation.height) / 2
        case .bottomLeft:  return (-translation.width + translation.height) / 2
        case .topRight:    return ( translation.width - translation.height) / 2
        case .topLeft:     return (-translation.width - translation.height) / 2
        }
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CameraViewFinder(size: .constant(150.0))
    }
    .environment(CameraRepository.shared)
    .environment(CompassRepository())
}

