//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import Foundation

class FileLogDestination: LogDestination, @unchecked Sendable {
    
    private let fileManager = FileManager.default
    private let logFileURL: URL
    private let maxFileSize: Int = 5 * 1024 * 1024
    private let queue = DispatchQueue(label: "com.logger.file", qos: .utility)
    private var fileHandle: FileHandle?
    private var currentFileSize: Int = 0
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logsDirectory = documentsPath.appendingPathComponent("Logs", isDirectory: true)
        
        try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        self.logFileURL = logsDirectory.appendingPathComponent("log_\(dateString).txt")
        
        // Initialize file handle and size
        if !fileManager.fileExists(atPath: logFileURL.path) {
            fileManager.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
        }
        
        if let handle = try? FileHandle(forWritingTo: logFileURL) {
            self.fileHandle = handle
            self.fileHandle?.seekToEndOfFile()
            
            // Get initial file size
            if let attributes = try? fileManager.attributesOfItem(atPath: logFileURL.path),
               let size = attributes[.size] as? Int {
                self.currentFileSize = size
            }
        }
    }
    
    deinit {
        try? fileHandle?.close()
    }
    
    func log(_ entry: LogEntry) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let timestamp = ISO8601DateFormatter().string(from: entry.timestamp)
            let fileName = (entry.file as NSString).lastPathComponent
            let logMessage = "\(timestamp) \(entry.level.icon) [\(entry.level.name)] [\(fileName):\(entry.line)] \(entry.function) -> \(entry.message)\n"
            
            guard let data = logMessage.data(using: .utf8) else { return }
            
            self.rotateLogFileIfNeeded(appendingDataSize: data.count)
            
            if let fileHandle = self.fileHandle {
                fileHandle.write(data)
                self.currentFileSize += data.count
            }
        }
    }
    
    private func rotateLogFileIfNeeded(appendingDataSize: Int) {
        if currentFileSize + appendingDataSize > maxFileSize {
            // Close current handle
            try? fileHandle?.close()
            fileHandle = nil
            
            let timestamp = Int(Date().timeIntervalSince1970)
            let archiveURL = logFileURL.deletingLastPathComponent()
                .appendingPathComponent("log_archive_\(timestamp).txt")
            
            try? fileManager.moveItem(at: logFileURL, to: archiveURL)
            
            // Create new file
            fileManager.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
            currentFileSize = 0
            
            // Re-open handle
            if let handle = try? FileHandle(forWritingTo: logFileURL) {
                self.fileHandle = handle
            }
        }
    }
    
    func getLogFileURL() -> URL {
        return logFileURL
    }
}
