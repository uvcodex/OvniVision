//
//  CameraLens.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/11/26.
//
import Foundation
import AVFoundation


// MARK: - CameraLens model

struct CameraLens: Identifiable, Equatable {
    let id: String // unique key derived from zoom factor
    let type: AVCaptureDevice.DeviceType
    let zoomFactor: CGFloat // target videoZoomFactor on the virtual device
    
    
    // display string ("0.5×", "1×", "3×", …)
    var label: String {
        switch type {
        case .builtInUltraWideCamera: return ".5×"
        case .builtInWideAngleCamera: return "1×"
        case .builtInTelephotoCamera: return "3×"
        default:                       return "1×"
        }
    }
    
    static func == (lhs: CameraLens, rhs: CameraLens) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.zoomFactor == rhs.zoomFactor
    }
}

