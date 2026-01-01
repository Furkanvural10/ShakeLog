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
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logsDirectory = documentsPath.appendingPathComponent("Logs", isDirectory: true)
        
        try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        self.logFileURL = logsDirectory.appendingPathComponent("log_\(dateString).txt")
    }
    
    func log(_ entry: LogEntry) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let timestamp = ISO8601DateFormatter().string(from: entry.timestamp)
            let fileName = (entry.file as NSString).lastPathComponent
            let logMessage = "\(timestamp) \(entry.level.icon) [\(entry.level.name)] [\(fileName):\(entry.line)] \(entry.function) -> \(entry.message)\n"
            
            self.rotateLogFileIfNeeded()
            
            if let data = logMessage.data(using: .utf8) {
                if fileManager.fileExists(atPath: logFileURL.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } else {
                    try? data.write(to: logFileURL, options: .atomic)
                }
            }
        }
    }
    
    private func rotateLogFileIfNeeded() {
        guard let attributes = try? fileManager.attributesOfItem(atPath: logFileURL.path),
              let fileSize = attributes[.size] as? Int,
              fileSize > maxFileSize else {
            return
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let archiveURL = logFileURL.deletingLastPathComponent()
            .appendingPathComponent("log_archive_\(timestamp).txt")
        
        try? fileManager.moveItem(at: logFileURL, to: archiveURL)
    }
    
    func getLogFileURL() -> URL {
        return logFileURL
    }
}
