//
//  ObjectBox.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import Foundation
import ObjectBox

final class ObjectBoxStore {

    static let shared = ObjectBoxStore()

    let store: Store

    // MARK: - Directories

    static let videosDirectory: URL = {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Videos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private static var storeDirectory: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("objectbox", isDirectory: true)
    }

    // MARK: - Init

    private init() {
        do {
            store = try Store(directory: Self.storeDirectory.path)
        } catch {
            fatalError("ObjectBox Store failed to open: \(error)")
        }
    }

    // MARK: - Boxes

    var videoBox: Box<VideoRecord> {
        store.box(for: VideoRecord.self)
    }
}
