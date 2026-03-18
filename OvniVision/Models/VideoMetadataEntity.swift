//
//  RecordingMetadata.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/18/26.
//

import Foundation
import ObjectBox

struct MetadataSnapshot: Codable {
    let timeOffset: Double      // seconds from recording start

    // Compass
    let heading: Double         // magnetic heading in degrees

    // GPS (future)
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?       // meters

    // Accelerometer (future)
    var accelerationX: Double?  // G-force
    var accelerationY: Double?
    var accelerationZ: Double?

    // Tilt (future)
    var pitch: Double?          // degrees
    var roll: Double?           // degrees
    var yaw: Double?            // degrees
}

// objectbox: entity
class VideoMetadataEntity {
    var id: Id = 0              // objectbox: id
    var videoFileName: String = ""
    var snapshotsJSON: String = ""

    init(videoFileName: String = "", snapshotsJSON: String = "") {
        self.videoFileName = videoFileName
        self.snapshotsJSON = snapshotsJSON
    }

    var snapshots: [MetadataSnapshot] {
        guard let data = snapshotsJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([MetadataSnapshot].self, from: data)
        else { return [] }
        return decoded
    }
}
