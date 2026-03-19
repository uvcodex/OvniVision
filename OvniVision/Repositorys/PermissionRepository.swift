//
//  PermissionRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/19/26.
//

import Foundation
import AVFoundation

@Observable
final class PermissionRepository {
    static let shared = PermissionRepository()

    var cameraStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    // Type inferred — AVAudioApplication.RecordPermission cannot be named directly
    var micStatus = AVAudioApplication.shared.recordPermission

    var canOpenCamera: Bool {
        cameraStatus == .authorized && micStatus == .granted
    }

    var isCameraDenied: Bool {
        cameraStatus == .denied || cameraStatus == .restricted
    }

    var isMicDenied: Bool {
        micStatus == .denied
    }

    func requestCamera() async {
        guard cameraStatus == .notDetermined else { return }
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        await MainActor.run { cameraStatus = granted ? .authorized : .denied }
    }

    func requestMic() async {
        guard micStatus != .granted, micStatus != .denied else { return }
        _ = await AVAudioApplication.requestRecordPermission()
        await MainActor.run { micStatus = AVAudioApplication.shared.recordPermission }
    }
}
