//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import Foundation


public struct LogEntry: Sendable {
    let timestamp: Date
    let level: LogLevel
    let message: String
    let file: String
    let function: String
    let line: Int
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
}
