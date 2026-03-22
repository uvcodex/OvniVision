//
//  NoVideosScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/19/26.
//

import SwiftUI

struct NoVideosScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("app_icon")
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.pink)
                .frame(width: 35, height: 35)

            Text("No recordings yet")
                .font(.custom("JetBrainsMono-Regular", size: 16))
                .foregroundStyle(.gray)

            Text("Tap the camera button below to start recording.")
                .font(.custom("JetBrainsMono-Regular", size: 12))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackgroundGradient()
    }
}

#Preview {
    NoVideosScreen()
}
