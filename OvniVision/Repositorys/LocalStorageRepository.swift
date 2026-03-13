//
//  ObjectBoxStore.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import Foundation
import ObjectBox

protocol LocalApi {
    var store: Store { get }
}

final class LocalStoreRepository: LocalApi {
    private init() {
        do {
            store = try Store(directoryPath: Self.storeDirectory.path)
        } catch {
            fatalError("ObjectBox Store failed to open: \(error)")
        }
    }
    
    static let shared = LocalStoreRepository()
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
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("objectbox", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

}
