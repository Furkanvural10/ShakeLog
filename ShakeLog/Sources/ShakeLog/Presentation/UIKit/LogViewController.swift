//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import UIKit


@available(iOS 13.0.0, *)
protocol LogViewControllerInterface: AnyObject {
    func setupUI() async
}


@available(iOS 13.0.0, *)
final class LogViewController: UIViewController {
    
    private var allLogs: [LogEntry] = []
    private var filteredLogs: [LogEntry] = []
    private var selectedLevel: LogLevel?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.separatorStyle = .singleLine
        return table
    }()
    
    private let filterSegmentedControl: UISegmentedControl = {
        let items = ["All"] + LogLevel.allCases.map { $0.icon }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search logs..."
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogs()
    }
    
    private func setupUI() {
        title = "App Logs"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        let exportButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(exportTapped)
        )
        
        let clearButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )
        
        navigationItem.rightBarButtonItems = [exportButton, clearButton]
        

        view.addSubview(searchBar)
        view.addSubview(filterSegmentedControl)
        view.addSubview(headerLabel)
        view.addSubview(tableView)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LogCell.self, forCellReuseIdentifier: "LogCell")
        

        searchBar.delegate = self
        
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            headerLabel.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadLogs() {
        allLogs = Logger.shared.getMemoryLogs()
        filterLogs()
        updateHeader()
    }
    
    private func filterLogs() {
        filteredLogs = allLogs
        
        if let level = selectedLevel {
            filteredLogs = filteredLogs.filter { $0.level == level }
        }
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredLogs = filteredLogs.filter {
                $0.message.localizedCaseInsensitiveContains(searchText) ||
                $0.function.localizedCaseInsensitiveContains(searchText) ||
                $0.file.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        tableView.reloadData()
    }
    
    private func updateHeader() {
        headerLabel.text = "Showing \(filteredLogs.count) of \(allLogs.count) logs"
    }
    
    @objc private func filterChanged() {
        let index = filterSegmentedControl.selectedSegmentIndex
        selectedLevel = index == 0 ? nil : LogLevel.allCases[index - 1]
        filterLogs()
        updateHeader()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func exportTapped() {
        let exportString = Logger.shared.exportLogs()
        let activityVC = UIActivityViewController(
            activityItems: [exportString],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func clearTapped() {
        let alert = UIAlertController(
            title: "Clear Logs",
            message: "Are you sure you want to clear all logs?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            Logger.shared.clearMemoryLogs()
            self?.loadLogs()
        })
        
        present(alert, animated: true)
    }
}


@available(iOS 13.0.0, *)
extension LogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogCell
        let log = filteredLogs[indexPath.row]
        cell.configure(with: log)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let log = filteredLogs[indexPath.row]
        showLogDetail(log)
    }
    
    private func showLogDetail(_ log: LogEntry) {
        let fileName = (log.file as NSString).lastPathComponent
        
        let detail = """
        Time: \(log.formattedTimestamp)
        Level: \(log.level.icon) \(log.level.name)
        File: \(fileName):\(log.line)
        Function: \(log.function)
        
        Message:
        \(log.message)
        """
        
        let alert = UIAlertController(title: "Log Detail", message: detail, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = detail
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
}


@available(iOS 13.0.0, *)
extension LogViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterLogs()
        updateHeader()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
