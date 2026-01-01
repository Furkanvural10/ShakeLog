//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import Foundation
class MemoryLogDestination: LogDestination, @unchecked Sendable {
    
    private var logs: [LogEntry] = []
    private let maxLogs = 1000
    private let queue = DispatchQueue(label: "com.logger.memory")
    
    func log(_ entry: LogEntry) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.logs.append(entry)
            
            if self.logs.count > self.maxLogs {
                self.logs.removeFirst()
            }
        }
    }
    
    func getLogs() -> [LogEntry] {
        return queue.sync { logs }
    }
    
    func clearLogs() {
        queue.async { [weak self] in
            self?.logs.removeAll()
        }
    }
    
    func exportLogs() -> String {
        let allLogs = getLogs()
        var exportString = "=== App Logs Export ===\n"
        exportString += "Total Logs: \(allLogs.count)\n"
        exportString += "Export Date: \(Date())\n"
        exportString += "========================\n\n"
        
        for log in allLogs {
            let fileName = (log.file as NSString).lastPathComponent
            exportString += "\(log.formattedTimestamp) \(log.level.icon) [\(log.level.name)] [\(fileName):\(log.line)] \(log.function)\n"
            exportString += "  → \(log.message)\n\n"
        }
        
        return exportString
    }
}
