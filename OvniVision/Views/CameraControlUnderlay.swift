//
//  CameraControlUnderlay.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI

struct CameraControlUnderlay<Content: View>: View {
    var height: CGFloat = 140
    @ViewBuilder var content: Content
    
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .frame(height: height)
            .overlay {
                content
            }
    }
}

#Preview {
    CameraControlUnderlay {
        Text("Hello world")
    }
}
