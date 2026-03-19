//
//  CameraButton.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/18/26.
//

import SwiftUI

struct CameraButton: View {
    let icon: String
    var iconSize: CGFloat = 25
    var size: CGFloat = 55
    var color: Color = .blue
    var effect: Bool = false
    let action: () -> Void
    
    @State private var isActive = false
    
    var body: some View {
        Button {
            if effect {
                isActive.toggle()
            }
            action()
        } label: {
            Image(systemName: icon)
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.pulse, isActive: isActive)
                .frame(width: iconSize, height: iconSize)
                .frame(width: size, height: size)
        }
        .foregroundStyle(color)
        .glassEffect(.regular.tint(color.opacity(0.2)).interactive())
    }
}


#Preview {
    CameraButton(icon: "xmark") {
        print ("tapped")
    }
}
