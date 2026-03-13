//
//  VideoRecord.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import Foundation
import ObjectBox

// objectbox: entity
class VideoRecord {
    var id: Id = 0          // objectbox: id
    var fileName: String
    var duration: Double
    var fileSize: Int64
    var createdAt: Date

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
