//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import Foundation

protocol LogDestination: Sendable {
    func log(_ entry: LogEntry)
}
