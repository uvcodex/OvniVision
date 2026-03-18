//
//  PlaybackCompassView.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/18/26.
//

import SwiftUI

// MARK: - Playback compass data source

@Observable
final class PlaybackCompassRepository {
    var heading: Double = 0
    private(set) var hasData: Bool = false
    private var snapshots: [MetadataSnapshot] = []

    func load(videoFileName: String) {
        snapshots = MetadataRepository.shared.load(videoFileName: videoFileName)
        hasData = !snapshots.isEmpty
    }

    func update(currentTime: Double) {
        guard !snapshots.isEmpty else { return }
        heading = interpolatedHeading(at: currentTime)
    }

    private func interpolatedHeading(at time: Double) -> Double {
        guard let upperIdx = snapshots.firstIndex(where: { $0.timeOffset > time }) else {
            return snapshots.last?.heading ?? 0
        }
        if upperIdx == 0 { return snapshots[0].heading }
        let lower = snapshots[upperIdx - 1]
        let upper = snapshots[upperIdx]
        let t = (time - lower.timeOffset) / (upper.timeOffset - lower.timeOffset)
        return lerpHeading(from: lower.heading, to: upper.heading, t: t)
    }

    private func lerpHeading(from a: Double, to b: Double, t: Double) -> Double {
        var diff = b - a
        if diff >  180 { diff -= 360 }
        if diff < -180 { diff += 360 }
        var result = a + t * diff
        if result <   0 { result += 360 }
        if result >= 360 { result -= 360 }
        return result
    }
}

// MARK: - Playback compass strip view

struct PlaybackCompassView: View {
    let width: CGFloat
    let compassApi: PlaybackCompassRepository

    private let pxPerDeg: CGFloat = 3.8
    private let stripH: CGFloat = 55
    private var bottomY: CGFloat { stripH - 18 }

    private let hMajor: CGFloat = 15
    private let hMid:   CGFloat = 10
    private let hMinor: CGFloat =  5

    private let opMajor: Double = 0.80
    private let opMid:   Double = 0.65
    private let opMinor: Double = 0.50

    var body: some View {
        ZStack {
            Canvas { ctx, size in
                drawTape(ctx: ctx, size: size, heading: compassApi.heading)
            }
            .frame(width: width, height: stripH)
            .clipped()

            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 14, height: 9)
                .foregroundStyle(.red.opacity(0.8))
                .offset(y: 23)
        }
        .background(.ultraThinMaterial.opacity(0.75))
        .frame(width: width)
    }

    // MARK: – Canvas

    private func drawTape(ctx: GraphicsContext, size: CGSize, heading: Double) {
        let cx = size.width / 2
        let halfVis = Double(size.width / pxPerDeg) / 2.0 + 12.0
        let lo = heading - halfVis
        let hi = heading + halfVis

        var bl = Path()
        bl.move(to: CGPoint(x: 0, y: bottomY))
        bl.addLine(to: CGPoint(x: size.width, y: bottomY))
        ctx.stroke(bl, with: .color(.white.opacity(0.20)), lineWidth: 0.5)

        let step = 5
        let startStep = Int(floor(lo / Double(step))) * step
        let endStep   = Int(ceil(hi  / Double(step))) * step

        for i in stride(from: startStep, through: endStep, by: step) {
            let x = cx + CGFloat(Double(i) - heading) * pxPerDeg
            guard x >= 0, x <= size.width else { continue }
            let n = ((i % 360) + 360) % 360

            if n % 30 == 0 {
                let label      = tapeLabel(for: n)
                let isCardinal = n % 90 == 0
                tick(ctx, x: x, h: hMajor, op: opMajor, lw: 1.8)
                if isCardinal {
                    ctx.draw(
                        Text(label)
                            .font(.custom("JetBrainsMono-SemiBold", size: 11)),
                        at: CGPoint(x: x, y: bottomY + 12), anchor: .center
                    )
                    ctx.draw(
                        Text("\(n)")
                            .font(.custom("JetBrainsMono-SemiBold", size: 11))
                            .foregroundStyle(.orange.opacity(0.70)),
                        at: CGPoint(x: x, y: bottomY - hMajor - 8), anchor: .center
                    )
                } else {
                    ctx.draw(
                        Text(label)
                            .font(.custom("JetBrainsMono-SemiBold", size: 11))
                            .foregroundStyle(Color.orange.opacity(0.70)),
                        at: CGPoint(x: x, y: bottomY - hMajor - 8), anchor: .center
                    )
                }
            } else if n % 45 == 0 {
                let label = intercardinalLabel(for: n)
                tick(ctx, x: x, h: hMajor, op: opMajor * 0.90, lw: 1.6)
                ctx.draw(
                    Text(label)
                        .font(.custom("JetBrainsMono-SemiBold", size: 10))
                        .foregroundStyle(.white.opacity(0.85)),
                    at: CGPoint(x: x, y: bottomY + 12), anchor: .center
                )
            } else if n % 10 == 0 {
                tick(ctx, x: x, h: hMid,   op: opMid,   lw: 1.2)
            } else {
                tick(ctx, x: x, h: hMinor, op: opMinor, lw: 0.8)
            }
        }
    }

    private func tick(_ ctx: GraphicsContext, x: CGFloat, h: CGFloat, op: Double, lw: CGFloat) {
        var p = Path()
        p.move(to:    CGPoint(x: x, y: bottomY))
        p.addLine(to: CGPoint(x: x, y: bottomY - h))
        ctx.stroke(p, with: .color(.white.opacity(op)), lineWidth: lw)
    }

    // MARK: – Helpers

    private func tapeLabel(for deg: Int) -> String {
        switch deg {
        case   0: return "N"
        case  90: return "E"
        case 180: return "S"
        case 270: return "W"
        default:  return "\(deg)"
        }
    }

    private func intercardinalLabel(for deg: Int) -> String {
        switch deg {
        case  45: return "NE"
        case 135: return "SE"
        case 225: return "SW"
        case 315: return "NW"
        default:  return ""
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        let mock: PlaybackCompassRepository = {
            let r = PlaybackCompassRepository()
            r.update(currentTime: 0)
            return r
        }()
        PlaybackCompassView(width: 393, compassApi: mock)
    }
}
