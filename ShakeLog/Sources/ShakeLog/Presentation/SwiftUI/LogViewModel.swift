//
//  LogViewModel.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import Foundation
import Combine

@available(iOS 13.0, *)
class LogViewModel: ObservableObject {
    @Published var logs: [LogEntry] = []
    
    init() {
        loadLogs()
    }
    
    func loadLogs() {
        logs = Logger.shared.getMemoryLogs().reversed()
    }
    
    func clearLogs() {
        Logger.shared.clearMemoryLogs()
        loadLogs()
    }
    
    func exportLogs() -> String {
        return Logger.shared.exportLogs()
    }
}
