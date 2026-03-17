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

    @State private var size: CGFloat = 150
    @State private var dragStartSize: CGFloat = 150
    @State private var viewFinderPosition: CGSize = .zero
    @State private var viewFinderDrag: CGSize = .zero
    @State private var screenSize: CGSize = .zero

    private let minSize: CGFloat = 150
    private let maxSize: CGFloat = 350
    private let handleSize: CGFloat = 15
    private let previewZoom: CGFloat = 1.2

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
                        Spacer()
                        if let filterName = activeFilter?.displayName {
                            Text(filterName)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(6)
                    Spacer()
                }
            }
            .frame(width: size, height: size)
        }
        .padding(.top, 70)
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
