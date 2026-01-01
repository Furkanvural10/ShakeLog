//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 30.12.2025.
//

import Foundation
import OSLog

class ConsoleLogDestination: LogDestination, @unchecked Sendable {
    private let osLog: OSLog
    
    init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.app", category: String = "General") {
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    func log(_ entry: LogEntry) {
        let fileName = (entry.file as NSString).lastPathComponent
        let logMessage = "\(entry.level.icon) [\(entry.level.name)] [\(fileName):\(entry.line)] \(entry.function) -> \(entry.message)"
        
        os_log("%{public}@", log: osLog, type: entry.level.osLogType, logMessage)
        print(logMessage)
    }
}
