//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import Foundation
import UIKit
import OSLog

public enum LogLevel: Int, Comparable, CaseIterable, Codable, Sendable {
    
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case critical = 5
    
    var icon: String {
        switch self {
        case .verbose: return "💬"
        case .debug: return "🐞"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "🔴"
        case .critical: return "🔥"
        }
    }
    
    var name: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
    
    var color: UIColor {
        switch self {
        case .verbose: return .systemGray
        case .debug: return .systemBlue
        case .info: return .systemGreen
        case .warning: return .systemOrange
        case .error: return .systemRed
        case .critical: return .systemPurple
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .verbose, .debug: return .debug
        case .info: return .info
        case .warning, .error: return .error
        case .critical: return .fault
        }
    }
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
