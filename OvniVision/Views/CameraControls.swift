//
//  CameraControls.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI

struct CameraControls: View {
    @Binding var isPresented: Bool
    @Environment(CameraRepository.self) var cameraApi
    
    var body: some View {
        ZStack {
            // Background blur bar
            VStack {
                Spacer()
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 140)
                    .overlay(alignment: .top) {
                        Divider().opacity(0.3)
                    }
            }
            .safeAreaBar(edge: .top) {
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "chevron.down")
                            .frame(width: 45, height: 45)
                            .offset(y: 1)
                    }
                    .foregroundStyle(.red)
                    .glassEffect(.regular.tint(.red.opacity(0.3)).interactive())
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
           
            }
        }
        .ignoresSafeArea(edges: .bottom)
        
    }
}

#Preview {
    
    NavigationStack {
        CameraControls(isPresented: .constant(true))
            .environment(CameraRepository())
    }
}
