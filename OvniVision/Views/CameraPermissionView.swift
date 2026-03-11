//
//  CameraPermissionView.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//

import SwiftUI

struct CameraPermissionView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
               Image(systemName: "camera.fill")
                   .font(.system(size: 64))
                   .foregroundStyle(.white.opacity(0.6))

               Text("Camera Access Required")
                   .font(.title2.bold())
                   .foregroundStyle(.white)

               Text("Please allow camera and microphone access in Settings to use this app.")
                   .multilineTextAlignment(.center)
                   .foregroundStyle(.white.opacity(0.7))
                   .padding(.horizontal, 40)

               Button("Open Settings") {
                   if let url = URL(string: UIApplication.openSettingsURLString) {
                       UIApplication.shared.open(url)
                   }
               }
               .buttonStyle(.borderedProminent)
               .tint(.white)
               .foregroundStyle(.black)
           }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "chevron.down")
                }
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        CameraPermissionView(isPresented: .constant(true))
    }
}
