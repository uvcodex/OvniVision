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
    let thumbnail: UIImage?
    let fileURL: URL
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
            thumbnail: thumbnail,
            fileURL: record.fileURL
        )
    }
}
