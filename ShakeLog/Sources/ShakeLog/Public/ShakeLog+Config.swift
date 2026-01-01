//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import Foundation

public extension ShakeLog {
    struct Config {
        public enum PresentationMode {
            case uiKit
            case swiftUI
        }
        
        public var presentationMode: PresentationMode = .uiKit
        public var minimumLogLevel: LogLevel = .verbose
        
        public init() {}
    }
    
    @MainActor static var config = Config()
    @MainActor static func configure(_ config: Config) {
        self.config = config
        Logger.shared.setMinimumLogLevel(config.minimumLogLevel)
    }
}
