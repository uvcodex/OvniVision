//
//  CameraRecordingBadge.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import SwiftUI

struct CameraRecordingBadge: View {
    var duration: TimeInterval
    var isRecording: Bool
    var body: some View {
        HStack {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
                .opacity(isRecording ? 1 : 0)
                .animation(
                    isRecording
                    ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                    : .easeInOut(duration: 0.3),
                    value: isRecording
                )
            
            Text(duration.durationString)
                .opacity(isRecording ? 1 : 0.3)
                .font(.custom("JetBrainsMono-Regular", size: 18))
        }
    }
}

#Preview("Is not recording") {
    let cameraApi = CameraRepository.shared
    CameraRecordingBadge(
        duration: cameraApi.recordingDuration,
        isRecording: cameraApi.isRecording
    )
}

#Preview("Is recording") {
    CameraRecordingBadge(
        duration: 3723,
        isRecording: true
    )
}
