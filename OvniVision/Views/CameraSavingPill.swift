//
//  CameraSavingPill.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import SwiftUI

struct CameraSavingPill: View {
    @State private var savingOpacity: Double = 1.0
    
    var body: some View {
        Text("SAVING")
            .font(.custom("JetBrainsMono-SemiBold", size: 13))
            .foregroundStyle(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .background(Capsule().fill(.yellow))
            .opacity(savingOpacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    savingOpacity = 0.3
                }
            }
    }
}

#Preview {
    CameraSavingPill()
}
