//
//  MLogStoreExporter.swift
//  MLogStoreExporter
//
//  Created by monsoir on 4/12/23.
//

import OSLog

@available(iOS 15.0, *)
public class MLogStoreExporter {

    public init(ext: String = "log") {
        self.ext = ext
    }

    private let ext: String

    public func export(to directory: URL, filename: String = UUID().uuidString, startDate: Date, overrideIfNeeded: Bool = false) throws -> LogFile {
        try validate(directory: directory)

        let fullFileame = "\(filename).\(ext)"
        let fileURL: URL = {
            if #available(iOS 16.0, *) {
                return directory.appending(component: fullFileame, directoryHint: .notDirectory)
            } else {
                return directory.appendingPathComponent(fullFileame, isDirectory: false)
            }
        }()

        let fileHandle = try createFileHandle(at: fileURL, overrideIfNeeded: overrideIfNeeded)
        defer { fileHandle.closeFile() }

        try _export(at: startDate, to: fileHandle)
        return .init(name: filename, url: fileURL, ext: ext)
    }

    private func validate(directory: URL) throws {
        var isDirectory: ObjCBool = false
        let isDirectoryExist = FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory)
        if !isDirectoryExist || !isDirectory.boolValue {
            throw CreateLogFileFailure()
        }
    }

    private func createFileHandle(at url: URL, overrideIfNeeded: Bool) throws -> FileHandle {
        if FileManager.default.fileExists(atPath: url.path) && !overrideIfNeeded {
            throw CreateLogFileFailure()
        }

        guard FileManager.default.createFile(atPath: url.path, contents: nil) else { throw CreateLogFileFailure() }

        let handle = try FileHandle(forWritingTo: url)
        return handle
    }

    private func _export(at date: Date, to fileHandle: FileHandle) throws {
        try fileHandle.seekToEnd()

        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { throw BundleIdentifierNotFoundFailure() }

        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let start = store.position(date: date)
        let entries = try store.getEntries(
            with: [],
            at: start,
            matching: NSPredicate(format: "subsystem == %@", bundleIdentifier)
        )

        let jsonEncoder = JSONEncoder()

        try entries.forEach {
            if let entry = $0 as? OSLogEntryLog {
                let item = LogItem(entry: entry)
                let rawData = try jsonEncoder.encode(item)
                try fileHandle.write(contentsOf: rawData)
                if let newline = "\n".data(using: .utf8) {
                    try fileHandle.write(contentsOf: newline)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
extension MLogStoreExporter {
    public struct CreateLogFileFailure: LocalizedError {
        public var errorDescription: String? { "Failed to create a log file" }
    }

    public struct BundleIdentifierNotFoundFailure: LocalizedError {
        public var errorDescription: String? { "Bundle identifier not found" }
    }

    public struct LogFile {
        public let name: String
        public let url: URL
        public let ext: String

        public var fullName: String { "\(name).\(ext)" }
    }

    fileprivate struct LogItem: Encodable {

        let entry: OSLogEntryLog

        private enum CodingKeys: String, CodingKey {
            case date
            case timestamp
            case entry
            case category
            case thread
            case level
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode("\(entry.date)", forKey: .date)
            try container.encode(entry.date.timeIntervalSince1970, forKey: .timestamp)
            try container.encode(entry.composedMessage, forKey: .entry)
            try container.encode(entry.category, forKey: .category)
            try container.encode(entry.threadIdentifier, forKey: .thread)
            try container.encode(entry.level.rawValue, forKey: .level)
        }
    }
}
