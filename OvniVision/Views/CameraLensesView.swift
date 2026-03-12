//
//  CameraLensesView.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI
import AVFoundation

struct CameraLensesView: View {
    var lenses: [CameraLens]
    var activeLens: CameraLens?
    var onLensSelected: (CameraLens) -> Void = { _ in }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(lenses) { lens in
                let isActive = lens == activeLens
                Button {
                    onLensSelected(lens)
                } label: {
                    Text(lens.label)
                        .font(.custom("JetBrainsMono-Thin", size: 12))
                        .foregroundStyle(isActive ? .yellow : .white)
                        .frame(width: 35, height: 35)
                        .background(Circle().fill(
                            isActive ? Color.white.opacity(0.2) : .clear
                        ))
                }
            }
        }
    }
}

#Preview("3 Lenses (Default)") {
    let lenses = Array(MockCameraRepository.shared.availableLenses)
    ZStack {
        Color.black.ignoresSafeArea()
        CameraLensesView(lenses: lenses, activeLens: lenses.first) { lens in
            print(lens)
        }
    }
}

#Preview("2 Lenses") {
    let lenses = Array(MockCameraRepository.shared.availableLenses[1...])
    ZStack {
        Color.black.ignoresSafeArea()
        CameraLensesView(lenses: lenses, activeLens: lenses.first) { lens in
            print(lens)
        }
    }
}

#Preview("1 Lens") {
    let lenses = Array(MockCameraRepository.shared.availableLenses[2...])
    ZStack {
        Color.black.ignoresSafeArea()
        CameraLensesView(lenses: lenses, activeLens: lenses.first) { lens in
            print(lens)
        }
    }
}
