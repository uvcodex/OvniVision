//
//  NavigationInjector.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct AppNavigation<Content: View>: View {
    @State var isCameraPresented: Bool = false
    @ViewBuilder var content: Content
    
    var body: some View {
        NavigationStack {
            VStack {
                content
            }
            .safeAreaBar(edge: .bottom) {
                HStack {
                    Spacer()
                    Button {
                        isCameraPresented = true
                    } label: {
                        Image(systemName: "dot.viewfinder")
                            .resizable()
                            .frame(width: 23, height: 23)
                            .frame(width: 55, height: 55)
                    }
                    .foregroundStyle(.yellow)
                    .glassEffect(.regular.tint(.yellow.opacity(0.3)).interactive())
                }
                .padding(.horizontal, 16)
                .fullScreenCover(isPresented: $isCameraPresented) {
                    CameraScreen(isPresented: $isCameraPresented)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isCameraPresented = false
    AppNavigation() {
        Spacer()
    }
}
