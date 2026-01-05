//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 20.12.2025.
//


import Foundation
import UIKit

class Logger: @unchecked Sendable {
    static let shared = Logger()
    
    private var destinations: [LogDestination] = []
    private var minimumLogLevel: LogLevel = .verbose
    private let queue = DispatchQueue(label: "com.logger.main", qos: .utility)
    private let memoryDestination = MemoryLogDestination()
    
    private init() {
        destinations.append(ConsoleLogDestination())
        destinations.append(FileLogDestination())
        destinations.append(memoryDestination)
    }
    
    // MARK: - Configuration
    func setMinimumLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
    }
    
    func addDestination(_ destination: LogDestination) {
        destinations.append(destination)
    }
    
    func removeAllDestinations() {
        destinations.removeAll()
    }
    
    func getMemoryLogs() -> [LogEntry] {
        return memoryDestination.getLogs()
    }
    
    func clearMemoryLogs() {
        memoryDestination.clearLogs()
    }
    
    func exportLogs() -> String {
        return memoryDestination.exportLogs()
    }
    
    // MARK: - Logging Methods
    func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .verbose, file: file, function: function, line: line)
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, file: file, function: function, line: line)
    }
    
    // MARK: - Core Logging
    private func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard level >= minimumLogLevel else { return }
        
        let entry = LogEntry(
            timestamp: Date(),
            level: level,
            message: message,
            file: file,
            function: function,
            line: line
        )
        
        queue.async { [weak self] in
            self?.destinations.forEach { destination in
                destination.log(entry)
            }
        }
    }
}


extension Logger {
    func debug<T: Encodable>(_ object: T, title: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(object),
           let jsonString = String(data: data, encoding: .utf8) {
            let message = title.isEmpty ? jsonString : "\(title):\n\(jsonString)"
            debug(message, file: file, function: function, line: line)
        }
    }
    
    func logRequest(_ request: URLRequest, file: String = #file, function: String = #function, line: Int = #line) {
        var message = "🌐 Network Request\n"
        message += "URL: \(request.url?.absoluteString ?? "N/A")\n"
        message += "Method: \(request.httpMethod ?? "N/A")\n"
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            message += "Headers: \(headers)\n"
        }
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            message += "Body: \(bodyString)"
        }
        
        debug(message, file: file, function: function, line: line)
    }
    
    func logResponse(_ response: URLResponse?, data: Data?, error: Error?, file: String = #file, function: String = #function, line: Int = #line) {
        var message = "🌐 Network Response\n"
        
        if let httpResponse = response as? HTTPURLResponse {
            message += "Status Code: \(httpResponse.statusCode)\n"
            message += "URL: \(httpResponse.url?.absoluteString ?? "N/A")\n"
        }
        
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            message += "Data: \(responseString)\n"
        }
        
        if let error = error {
            self.error(message + "Error: \(error.localizedDescription)", file: file, function: function, line: line)
        } else {
            debug(message, file: file, function: function, line: line)
        }
    }
}
