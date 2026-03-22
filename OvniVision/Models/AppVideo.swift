//
//  AppVideo.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import AVFoundation
import UIKit

struct AppVideo: Identifiable {
    let id: Int
    let name: String
    let createdAt: Date
    let duration: Double
    let thumbnail: UIImage?
    let fileURL: URL
    let classifications: Set<VideoClassification>
}

extension AppVideo {
    static func fromBox(_ record: VideoRecord) async -> AppVideo {
        
        let asset = AVURLAsset(url: record.fileURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        
        let thumbnail: UIImage?
        if let cgImage = try? await generator.image(at: .zero).image {
            thumbnail = UIImage(cgImage: cgImage)
        } else {
            thumbnail = nil
        }
        return AppVideo(
            id: Int(record.id),
            name: record.fileName,
            createdAt: record.createdAt,
            duration: record.duration,
            thumbnail: thumbnail,
            fileURL: record.fileURL,
            classifications: record.classifications
        )
    }
}
