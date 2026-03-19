//
//  MetadataRepository.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/18/26.
//

import Foundation
import ObjectBox

// MARK: - Ring buffer + ObjectBox persistence for recording telemetry

final class MetadataRepository {
    static let shared = MetadataRepository()

    private init(capacity: Int = 7200, localApi: LocalApi = LocalStoreRepository.shared) {
        self.capacity = capacity
        self.buffer = Array(repeating: MetadataSnapshot(timeOffset: 0, heading: 0), count: capacity)
        self.localApi = localApi
    }

    private let localApi: LocalApi
    private var buffer: [MetadataSnapshot]
    private let capacity: Int
    private var writeIndex = 0
    private var count = 0

    // MARK: - Recording lifecycle

    func reset() {
        writeIndex = 0
        count = 0
    }

    /// Appends a snapshot into the ring buffer.
    func sample(heading: Double, timeOffset: Double, latitude: Double? = nil, longitude: Double? = nil) {
        var snapshot = MetadataSnapshot(timeOffset: timeOffset, heading: heading)
        snapshot.latitude = latitude
        snapshot.longitude = longitude
        buffer[writeIndex % capacity] = snapshot
        writeIndex += 1
        if count < capacity { count += 1 }
    }

    /// Persists the buffered snapshots to ObjectBox, keyed by videoFileName.
    func save(videoFileName: String) {
        let snapshots = orderedSnapshots()
        guard !snapshots.isEmpty,
              let data = try? JSONEncoder().encode(snapshots),
              let json = String(data: data, encoding: .utf8) else { return }
        let record = VideoMetadataEntity(videoFileName: videoFileName, snapshotsJSON: json)
        
        do {
            try localApi.store.box(for: VideoMetadataEntity.self).put(record)
        } catch {
            return
        }
    }

    /// Loads snapshots for a given videoFileName from ObjectBox.
    func load(videoFileName: String) -> [MetadataSnapshot] {
        guard let records = try? localApi.store.box(for: VideoMetadataEntity.self).all() else { return [] }
        return records.first { $0.videoFileName == videoFileName }?.snapshots ?? []
    }

    // MARK: - Private

    private func orderedSnapshots() -> [MetadataSnapshot] {
        if count < capacity {
            return Array(buffer[0..<count])
        }
        let start = writeIndex % capacity
        return Array(buffer[start...] + buffer[..<start])
    }
}
