//
//  CameraViewFinderCompass.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/16/26.
//

import SwiftUI

// MARK: - Compass strip view

struct CameraCompassView: View {
    var compassApi: CompassRepository
    
    private let pxPerDeg: CGFloat = 3.8
    private let stripH: CGFloat = 50
    private var bottomY: CGFloat { stripH - 18 }  // ticks grow UP from here
    
    // Aviation-standard 3-tier tick heights
    private let hMajor: CGFloat = 15   // every 30° — labeled (N, 30, 60, E …)
    private let hMid:   CGFloat = 10   // every 10°
    private let hMinor: CGFloat =  5   // every  5°
    
    // Tick opacities
    private let opMajor: Double = 0.80
    private let opMid:   Double = 0.65
    private let opMinor: Double = 0.50
    
    var body: some View {
        ZStack {
            Canvas { ctx, size in
                drawTape(ctx: ctx, size: size, heading: compassApi.heading)
            }

            // Triangle indicator — points up, sits just below tallest ticks
            VStack {
                Spacer()
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 14, height: 9)
                    .foregroundStyle(.red.opacity(0.8))
            }
        }
        .background(.ultraThinMaterial.opacity(0.75))
        .frame(height: stripH)
        .clipped()
    }
    
    // MARK: – Canvas
    
    private func drawTape(ctx: GraphicsContext, size: CGSize, heading: Double) {
        let cx = size.width / 2
        let halfVis = Double(size.width / pxPerDeg) / 2.0 + 12.0
        let lo = heading - halfVis
        let hi = heading + halfVis
        
        // ── Baseline ─────────────────────────────────────────────────────
        var bl = Path()
        bl.move(to: CGPoint(x: 0, y: bottomY))
        bl.addLine(to: CGPoint(x: size.width, y: bottomY))
        ctx.stroke(bl, with: .color(.white.opacity(0.20)), lineWidth: 0.5)
        
        // ── Single-pass ticks — aviation standard ─────────────────────────
        // Iterate every 5° so all three tiers land exactly on integer steps
        let step = 5
        let startStep = Int(floor(lo / Double(step))) * step
        let endStep   = Int(ceil(hi  / Double(step))) * step
        
        for i in stride(from: startStep, through: endStep, by: step) {
            let x = cx + CGFloat(Double(i) - heading) * pxPerDeg
            guard x >= 0, x <= size.width else { continue }
            let n = ((i % 360) + 360) % 360
            
            if n % 30 == 0 {
                // Major tick — N/E/S/W below, degree numbers above
                let label      = tapeLabel(for: n)
                let isCardinal = n % 90 == 0
                tick(ctx, x: x, h: hMajor, op: opMajor, lw: 1.8)
                if isCardinal {
                    // Letter below baseline
                    ctx.draw(
                        Text(label)
                            .font(.custom("JetBrainsMono-SemiBold", size: 11))
                        /*.foregroundStyle(Color.white)*/,
                        at: CGPoint(x: x, y: bottomY + 12), anchor: .center
                    )
                    // Number above ticks
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
                // Intercardinal — NE, SE, SW, NW below the baseline
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
    
    /// Aviation-standard tape label for a normalised degree value (0–359, multiples of 30).
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
    
    private func cardinalLabel(_ heading: Double) -> String {
        let dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return dirs[Int((heading + 22.5) / 45) % 8]
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State  var compassApi = CompassRepository()
    ZStack {
        Color.black.ignoresSafeArea()
        CameraCompassView(compassApi: compassApi)
    }
    .environment(compassApi)
}
