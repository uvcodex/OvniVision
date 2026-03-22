//
//  VideoRecord.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import Foundation
import ObjectBox

enum VideoClassification: String, CaseIterable {
    case airplane
    case uav
    case balloon
    case ufo
    case bird
    case satellite
    case rocket
    case unknown

    var displayName: String {
        switch self {
        case .airplane:  return "Airplane"
        case .uav:       return "UAV / Drone"
        case .balloon:   return "Balloon"
        case .ufo:       return "UFO / UAP"
        case .bird:      return "Bird"
        case .satellite: return "Satellite"
        case .rocket:    return "Rocket"
        case .unknown:   return "Unknown"
        }
    }
}

// objectbox: entity
class VideoRecord {
    var id: Id = 0          // objectbox: id
    var fileName: String
    var duration: Double
    var fileSize: Int64
    var createdAt: Date
    var classificationRaw: String = ""

    var classifications: Set<VideoClassification> {
        get {
            Set(classificationRaw.split(separator: ",").compactMap { VideoClassification(rawValue: String($0)) })
        }
        set {
            classificationRaw = newValue.map(\.rawValue).joined(separator: ",")
        }
    }

    init(fileName: String = "", duration: Double = 0, fileSize: Int64 = 0, createdAt: Date = Date()) {
        self.fileName = fileName
        self.duration = duration
        self.fileSize = fileSize
        self.createdAt = createdAt
    }

    /// Resolves the stored fileName back to its full URL in the app's Videos directory.
    var fileURL: URL {
        LocalStoreRepository.videosDirectory.appendingPathComponent(fileName)
    }
}
