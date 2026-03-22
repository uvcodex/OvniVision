//
//  VideosRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import Foundation
import ObjectBox

protocol VideosApi {
    var isLoading: Bool { get }
    var videos: [AppVideo] { get }

    func getVideos()
    func deleteVideo(_ video: AppVideo)
    func setClassifications(_ video: AppVideo, classifications: Set<VideoClassification>)
}

@Observable
final class VideosRepository: VideosApi {
    private init(localApi: LocalStoreRepository = .shared) {
        self.localApi = localApi
    }
    static let shared = VideosRepository()
    
    private let localApi: LocalApi
    var isLoading: Bool = false
    var videos: [AppVideo] = []

    func getVideos() {
        Task {
            await MainActor.run { self.isLoading = true }

            do {
                let records = try localApi.store.box(for: VideoRecord.self).all()
                var appVideos: [AppVideo] = []
                for record in records {
                    let video = await AppVideo.fromBox(record)
                    appVideos.append(video)
                }
                await MainActor.run { self.videos = appVideos }
            } catch {
                print(error.localizedDescription)
            }
            await MainActor.run { self.isLoading = false }
        }
    }

    func deleteVideo(_ video: AppVideo) {
        Task {
            do {
                let box = localApi.store.box(for: VideoRecord.self)
                try box.remove(Id(video.id))
                try FileManager.default.removeItem(at: video.fileURL)
                await MainActor.run {
                    self.videos.removeAll { $0.id == video.id }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func setClassifications(_ video: AppVideo, classifications: Set<VideoClassification>) {
        Task {
            do {
                let box = localApi.store.box(for: VideoRecord.self)
                if let record = try box.get(Id(video.id)) {
                    record.classifications = classifications
                    try box.put(record)
                    await MainActor.run {
                        if let index = self.videos.firstIndex(where: { $0.id == video.id }) {
                            let v = self.videos[index]
                            self.videos[index] = AppVideo(
                                id: v.id, name: v.name, createdAt: v.createdAt,
                                duration: v.duration, thumbnail: v.thumbnail,
                                fileURL: v.fileURL, classifications: classifications
                            )
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}
