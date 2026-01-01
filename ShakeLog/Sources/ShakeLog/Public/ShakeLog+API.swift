//
//  ShakeLog+API.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import Foundation

public extension ShakeLog {
    
    static func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.verbose(message, file: file, function: function, line: line)
    }
    
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.debug(message, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.info(message, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.warning(message, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.error(message, file: file, function: function, line: line)
    }
    
    static func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.critical(message, file: file, function: function, line: line)
    }
    
    
    static func debug<T: Encodable>(_ object: T, title: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.debug(object, title: title, file: file, function: function, line: line)
    }
    

    static func logRequest(_ request: URLRequest, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.logRequest(request, file: file, function: function, line: line)
    }
    
    static func logResponse(_ response: URLResponse?, data: Data?, error: Error?, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.logResponse(response, data: data, error: error, file: file, function: function, line: line)
    }
}
