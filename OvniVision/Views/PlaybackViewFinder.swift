//
//  PlaybackViewFinder.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/16/26.
//

import SwiftUI

struct PlaybackViewFinder: View {
    var filteredImage: CGImage? = nil
    var activeFilter: VideoFilter? = nil
    var trackApi: TrackObjectRepository? = nil
    var compassApi: PlaybackCompassRepository? = nil

    @State private var size: CGFloat = 150
    @State private var dragStartSize: CGFloat = 150
    @State private var viewFinderPosition: CGSize = .zero
    @State private var viewFinderDrag: CGSize = .zero
    @State private var screenSize: CGSize = .zero
    @State private var peepholeGlobalMid: CGPoint = .zero

    private let minSize: CGFloat = 80
    private var maxSize: CGFloat { screenSize.width * 0.9 }
    private var initialSize: CGFloat { screenSize.width * 0.45 }
    private var centerOffset: CGFloat { screenSize.height * 0.10 }
    private let handleSize: CGFloat = 15
    @State private var previewZoom: CGFloat = 1.2

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
                        Image(decorative: cgImage, scale: 1, orientation: .right)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenSize.width * previewZoom, height: screenSize.height * previewZoom)
                            .position(
                                x: size / 2 + previewZoom * (screenSize.width / 2 - globalFrame.midX),
                                y: size / 2 + previewZoom * (screenSize.height / 2 - globalFrame.midY)
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

                VStack {
                    HStack {
                        if let api = compassApi, api.hasData {
                            Text("\(Int(api.heading.rounded()))° \(cardinalLabel(api.heading))")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                        if trackApi?.isTracking == true {
                            Text("TRACKING")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(6)
                    Spacer()
                    HStack {
                        if let filterName = activeFilter?.displayName {
                            Text(filterName)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                    }
                    .padding(6)
                }
            }
            .frame(width: size, height: size)
            // Capture the peephole's global mid-point for tracking coordinate math
            .background {
                GeometryReader { geo in
                    let frame = geo.frame(in: .global)
                    Color.clear
                        .onAppear {
                            peepholeGlobalMid = CGPoint(x: frame.midX, y: frame.midY)
                            updatePeepholeBox()
                        }
                        .onChange(of: frame.midX) { _, x in
                            peepholeGlobalMid = CGPoint(x: x, y: peepholeGlobalMid.y)
                            updatePeepholeBox()
                        }
                        .onChange(of: frame.midY) { _, y in
                            peepholeGlobalMid = CGPoint(x: peepholeGlobalMid.x, y: y)
                            updatePeepholeBox()
                        }
                }
            }

            Slider(value: $previewZoom, in: 1...10, step: 0.1)
                .tint(.orange)
                .frame(width: size)
                .opacity(0.5)
        }
        .offset(
            x: viewFinderPosition.width + viewFinderDrag.width,
            y: viewFinderPosition.height + viewFinderDrag.height - centerOffset
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
        .onChange(of: size) { updatePeepholeBox() }
        .onChange(of: trackApi?.trackedBounds) { _, bounds in
            guard trackApi?.isTracking == true, let bounds else { return }
            // Derive the viewfinder's natural (zero-offset) position, then shift to track the object.
            let naturalX = peepholeGlobalMid.x - viewFinderPosition.width
            let naturalY = peepholeGlobalMid.y - viewFinderPosition.height
            let targetX = bounds.midX * screenSize.width
            let targetY = (1 - bounds.midY) * screenSize.height  // flip Vision y
            viewFinderPosition.width  = targetX - naturalX
            viewFinderPosition.height = targetY - naturalY
        }
        .onAppear {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            screenSize = scene.screen.bounds.size
            size = initialSize
            dragStartSize = size
        }
    }

    // MARK: - Tracking coordinate helpers

    /// Updates trackApi.peepholeNormalizedBox from current peephole position and size.
    private func updatePeepholeBox() {
        guard screenSize.width > 0, screenSize.height > 0, let trackApi else { return }
        trackApi.peepholeNormalizedBox = computeNormalizedBox(mid: peepholeGlobalMid)
    }

    /// Converts the peephole center + size to a Vision normalized bounding box.
    /// Vision uses bottom-left origin; x/y each 0…1.
    private func computeNormalizedBox(mid: CGPoint) -> CGRect {
        let W = screenSize.width, H = screenSize.height, z = previewZoom
        let x = mid.x / W - size / (2 * W * z)
        let y = 1 - mid.y / H - size / (2 * H * z)   // flip y for Vision bottom-left
        let w = size / (W * z)
        let h = size / (H * z)
        return CGRect(x: x, y: y, width: w, height: h)
    }

    // MARK: - Corner handles

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

private enum Corner: CaseIterable, Hashable {
    case topLeft, topRight, bottomLeft, bottomRight

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
        PlaybackViewFinder()
    }
}
