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
    func handleFilterLogs(searchBarText: String) async
    func handleFilterChanged(index: Int) async
    func handleClearButtonTapped() async
    
    func getNumberOfRowsInSection() -> Int
    func getItem(indexPath: IndexPath) -> LogEntry

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
        await view?.updateHeader(filteredLogs: filteredLogs.count, allLogs: dataSource.count)
    }
    
    func handleFilterLogs(searchBarText: String) async {
        filteredLogs = dataSource
        
        if let level = selectedLevel {
            filteredLogs = filteredLogs.filter { $0.level == level }
        }
        
        if !searchBarText.isEmpty {
            filteredLogs = filteredLogs.filter {
                $0.message.localizedCaseInsensitiveContains(searchBarText) ||
                $0.function.localizedCaseInsensitiveContains(searchBarText) ||
                $0.file.localizedCaseInsensitiveContains(searchBarText)
            }
        }
        
        await view?.reloadTableView()
    }
    
    func handleFilterChanged(index: Int) async {
        selectedLevel = index == 0 ? nil : LogLevel.allCases[index - 1]
        await handleFilterLogs(searchBarText: "")
        await view?.updateHeader(filteredLogs: filteredLogs.count, allLogs: dataSource.count)
    }
    
    func handleClearButtonTapped() async {
        Logger.shared.clearMemoryLogs()
        await LoadLogs()
    }
    
    func getNumberOfRowsInSection() -> Int {
        return filteredLogs.count
    }
    
    func getItem(indexPath: IndexPath) -> LogEntry {
        return filteredLogs[indexPath.row]
    }
    
    
}
