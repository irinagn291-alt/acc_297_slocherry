import Foundation

/// Role: Field. Projects Field to UserDefaults tnd.field.v1 plus an atomic Application Support file. Views never touch this type.
actor FieldVault {
    private let directory: URL
    private let suiteName: String?
    private let fileManager: FileManager

    init(
        directory: URL,
        suiteName: String? = nil,
        fileManager: FileManager = .default
    ) {
        self.directory = directory
        self.suiteName = suiteName
        self.fileManager = fileManager
    }

    nonisolated static func applicationSupportDirectory(fileManager: FileManager = .default) throws -> URL {
        let root = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return root.appendingPathComponent("Slocherry", isDirectory: true)
    }

    func load() -> (field: Field, warning: FieldWarning?) {
        if let field = decode(defaults().data(forKey: FieldKey.snapshot)) {
            return (field, nil)
        }
        if let field = decode(read(fileURL)) {
            return (field, nil)
        }
        if let field = decode(defaults().data(forKey: FieldKey.backup)) {
            return (field, .recoveredFromBackup)
        }
        if let field = decode(read(backupURL)) {
            return (field, .recoveredFromBackup)
        }
        let hadPayload = defaults().data(forKey: FieldKey.snapshot) != nil
            || fileManager.fileExists(atPath: fileURL.path)
        return (.empty, hadPayload ? .startedEmpty : nil)
    }

    func save(_ field: Field) throws {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try FieldDocument.encode(field)
        let box = defaults()
        if let current = box.data(forKey: FieldKey.snapshot) {
            box.set(current, forKey: FieldKey.backup)
        }
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: backupURL)
            try? fileManager.copyItem(at: fileURL, to: backupURL)
        }
        box.set(data, forKey: FieldKey.snapshot)
        try data.write(to: fileURL, options: .atomic)
        excludeCacheIfPresent()
    }

    func wipe() throws {
        let box = defaults()
        box.removeObject(forKey: FieldKey.snapshot)
        box.removeObject(forKey: FieldKey.backup)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        if fileManager.fileExists(atPath: backupURL.path) {
            try fileManager.removeItem(at: backupURL)
        }
        if fileManager.fileExists(atPath: cacheURL.path) {
            try fileManager.removeItem(at: cacheURL)
        }
    }

    func demoPlanted() -> Bool {
        defaults().object(forKey: FieldKey.demo) != nil
    }

    func markDemoPlanted() {
        defaults().set(true, forKey: FieldKey.demo)
    }

    private func decode(_ data: Data?) -> Field? {
        guard let data else { return nil }
        return try? FieldDocument.decode(data)
    }

    private func read(_ url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    private var fileURL: URL {
        directory.appendingPathComponent("field.json", isDirectory: false)
    }

    private var backupURL: URL {
        directory.appendingPathComponent("field.json.backup", isDirectory: false)
    }

    private var cacheURL: URL {
        directory.appendingPathComponent("catalog-cache.json", isDirectory: false)
    }

    private func excludeCacheIfPresent() {
        guard fileManager.fileExists(atPath: cacheURL.path) else { return }
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var url = cacheURL
        try? url.setResourceValues(values)
    }

    private func defaults() -> UserDefaults {
        if let suiteName {
            return UserDefaults(suiteName: suiteName) ?? .standard
        }
        return .standard
    }
}
