//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 2.01.2026.
//

import Foundation

@available(iOS 13.0.0, *)
protocol LogViewModelInterface {
    
    var view: LogViewControllerInterface? { get set }
    var dataSource: [LogEntry] { get }
    var filteredLogs: [LogEntry] { get }
    var selectedLevel: LogLevel? { get }

    func handleViewDidLoad() async

}


@available(iOS 13.0.0, *)
final class LogViewControllerModel {
    weak var view: (any LogViewControllerInterface)?
    private(set) var dataSource: [LogEntry] = []
    private(set) var filteredLogs: [LogEntry] = []
    var selectedLevel: LogLevel?
}

@available(iOS 13.0.0, *)
extension LogViewControllerModel: LogViewModelInterface {
    
    func handleViewDidLoad() async {
        await LoadLogs()
        await view?.setupUI()
        
    }
    
    private func LoadLogs() async {
        dataSource = Logger.shared.getMemoryLogs()
        view?.updateHeader(filteredLogs: filteredLogs.count, allLogs: dataSource.count)
    }
    
    private func filterLogs() {
        filteredLogs = dataSource
        
        if let level = selectedLevel {
            filteredLogs = filteredLogs.filter { $0.level == level }
        }
        
        
        // TableView reload !!
    }
}
