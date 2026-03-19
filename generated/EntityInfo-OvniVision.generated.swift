// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata

extension VideoMetadataEntity: ObjectBox.Entity {}
extension VideoRecord: ObjectBox.Entity {}

extension VideoMetadataEntity: ObjectBox.__EntityRelatable {
    internal typealias EntityType = VideoMetadataEntity

    internal var _id: EntityId<VideoMetadataEntity> {
        return EntityId<VideoMetadataEntity>(self.id.value)
    }
}

extension VideoMetadataEntity: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = VideoMetadataEntityBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static let entityInfo = ObjectBox.EntityInfo(name: "VideoMetadataEntity", id: 3)

    internal static let entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: VideoMetadataEntity.self, id: 3, uid: 5892671307537721856)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 970109829040567552)
        try entityBuilder.addProperty(name: "videoFileName", type: PropertyType.string, id: 2, uid: 132955011840617472)
        try entityBuilder.addProperty(name: "snapshotsJSON", type: PropertyType.string, id: 3, uid: 776291641127707648)

        try entityBuilder.lastProperty(id: 3, uid: 776291641127707648)
    }
}

extension VideoMetadataEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { VideoMetadataEntity.id == myId }
    internal static var id: Property<VideoMetadataEntity, Id, Id> { return Property<VideoMetadataEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { VideoMetadataEntity.videoFileName.startsWith("X") }
    internal static var videoFileName: Property<VideoMetadataEntity, String, Void> { return Property<VideoMetadataEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { VideoMetadataEntity.snapshotsJSON.startsWith("X") }
    internal static var snapshotsJSON: Property<VideoMetadataEntity, String, Void> { return Property<VideoMetadataEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == VideoMetadataEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<VideoMetadataEntity, Id, Id> { return Property<VideoMetadataEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .videoFileName.startsWith("X") }

    internal static var videoFileName: Property<VideoMetadataEntity, String, Void> { return Property<VideoMetadataEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .snapshotsJSON.startsWith("X") }

    internal static var snapshotsJSON: Property<VideoMetadataEntity, String, Void> { return Property<VideoMetadataEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `VideoMetadataEntity.EntityBindingType`.
internal final class VideoMetadataEntityBinding: ObjectBox.EntityBinding, Sendable {
    internal typealias EntityType = VideoMetadataEntity
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_videoFileName = propertyCollector.prepare(string: entity.videoFileName)
        let propertyOffset_snapshotsJSON = propertyCollector.prepare(string: entity.snapshotsJSON)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_videoFileName, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_snapshotsJSON, at: 2 + 2 * 3)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = VideoMetadataEntity()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.videoFileName = entityReader.read(at: 2 + 2 * 2)
        entity.snapshotsJSON = entityReader.read(at: 2 + 2 * 3)

        return entity
    }
}



extension VideoRecord: ObjectBox.__EntityRelatable {
    internal typealias EntityType = VideoRecord

    internal var _id: EntityId<VideoRecord> {
        return EntityId<VideoRecord>(self.id.value)
    }
}

extension VideoRecord: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = VideoRecordBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static let entityInfo = ObjectBox.EntityInfo(name: "VideoRecord", id: 2)

    internal static let entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: VideoRecord.self, id: 2, uid: 7901256109789101056)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 4560619986994703872)
        try entityBuilder.addProperty(name: "fileName", type: PropertyType.string, id: 2, uid: 2250729217741557504)
        try entityBuilder.addProperty(name: "duration", type: PropertyType.double, id: 3, uid: 1675763787199144960)
        try entityBuilder.addProperty(name: "fileSize", type: PropertyType.long, id: 4, uid: 2171531535568340992)
        try entityBuilder.addProperty(name: "createdAt", type: PropertyType.date, id: 5, uid: 7445788275019126784)

        try entityBuilder.lastProperty(id: 5, uid: 7445788275019126784)
    }
}

extension VideoRecord {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { VideoRecord.id == myId }
    internal static var id: Property<VideoRecord, Id, Id> { return Property<VideoRecord, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { VideoRecord.fileName.startsWith("X") }
    internal static var fileName: Property<VideoRecord, String, Void> { return Property<VideoRecord, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { VideoRecord.duration > 1234 }
    internal static var duration: Property<VideoRecord, Double, Void> { return Property<VideoRecord, Double, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { VideoRecord.fileSize > 1234 }
    internal static var fileSize: Property<VideoRecord, Int64, Void> { return Property<VideoRecord, Int64, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { VideoRecord.createdAt > 1234 }
    internal static var createdAt: Property<VideoRecord, Date, Void> { return Property<VideoRecord, Date, Void>(propertyId: 5, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == VideoRecord {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<VideoRecord, Id, Id> { return Property<VideoRecord, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .fileName.startsWith("X") }

    internal static var fileName: Property<VideoRecord, String, Void> { return Property<VideoRecord, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .duration > 1234 }

    internal static var duration: Property<VideoRecord, Double, Void> { return Property<VideoRecord, Double, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .fileSize > 1234 }

    internal static var fileSize: Property<VideoRecord, Int64, Void> { return Property<VideoRecord, Int64, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .createdAt > 1234 }

    internal static var createdAt: Property<VideoRecord, Date, Void> { return Property<VideoRecord, Date, Void>(propertyId: 5, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `VideoRecord.EntityBindingType`.
internal final class VideoRecordBinding: ObjectBox.EntityBinding, Sendable {
    internal typealias EntityType = VideoRecord
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_fileName = propertyCollector.prepare(string: entity.fileName)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.duration, at: 2 + 2 * 3)
        propertyCollector.collect(entity.fileSize, at: 2 + 2 * 4)
        propertyCollector.collect(entity.createdAt, at: 2 + 2 * 5)
        propertyCollector.collect(dataOffset: propertyOffset_fileName, at: 2 + 2 * 2)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = VideoRecord()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.fileName = entityReader.read(at: 2 + 2 * 2)
        entity.duration = entityReader.read(at: 2 + 2 * 3)
        entity.fileSize = entityReader.read(at: 2 + 2 * 4)
        entity.createdAt = entityReader.read(at: 2 + 2 * 5)

        return entity
    }
}


/// Helper function that allows calling Enum(rawValue: value) with a nil value, which will return nil.
fileprivate func optConstruct<T: RawRepresentable>(_ type: T.Type, rawValue: T.RawValue?) -> T? {
    guard let rawValue = rawValue else { return nil }
    return T(rawValue: rawValue)
}

// MARK: - Store setup

fileprivate func cModel() throws -> OpaquePointer {
    let modelBuilder = try ObjectBox.ModelBuilder()
    try VideoMetadataEntity.buildEntity(modelBuilder: modelBuilder)
    try VideoRecord.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 3, uid: 5892671307537721856)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    /// A store with a fully configured model. Created by the code generator with your model's metadata in place.
    ///
    /// # In-memory database
    /// To use a file-less in-memory database, instead of a directory path pass `memory:` 
    /// together with an identifier string:
    /// ```swift
    /// let inMemoryStore = try Store(directoryPath: "memory:test-db")
    /// ```
    ///
    /// - Parameters:
    ///   - directoryPath: The directory path in which ObjectBox places its database files for this store,
    ///     or to use an in-memory database `memory:<identifier>`.
    ///   - maxDbSizeInKByte: Limit of on-disk space for the database files. Default is `1024 * 1024` (1 GiB).
    ///   - fileMode: UNIX-style bit mask used for the database files; default is `0o644`.
    ///     Note: directories become searchable if the "read" or "write" permission is set (e.g. 0640 becomes 0750).
    ///   - maxReaders: The maximum number of readers.
    ///     "Readers" are a finite resource for which we need to define a maximum number upfront.
    ///     The default value is enough for most apps and usually you can ignore it completely.
    ///     However, if you get the maxReadersExceeded error, you should verify your
    ///     threading. For each thread, ObjectBox uses multiple readers. Their number (per thread) depends
    ///     on number of types, relations, and usage patterns. Thus, if you are working with many threads
    ///     (e.g. in a server-like scenario), it can make sense to increase the maximum number of readers.
    ///     Note: The internal default is currently around 120. So when hitting this limit, try values around 200-500.
    ///   - readOnly: Opens the database in read-only mode, i.e. not allowing write transactions.
    ///
    /// - important: This initializer is created by the code generator. If you only see the internal `init(model:...)`
    ///              initializer, trigger code generation by building your project.
    internal convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024,
                            fileMode: UInt32 = 0o644, maxReaders: UInt32 = 0, readOnly: Bool = false) throws {
        try self.init(
            model: try cModel(),
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders,
            readOnly: readOnly)
    }
}

// swiftlint:enable all
