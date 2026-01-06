//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 26.12.2025.
//

import UIKit


@available(iOS 13.0.0, *)
@MainActor
protocol LogViewControllerInterface: AnyObject {
    func setupUI() async
    func updateHeader(filteredLogs: Int, allLogs: Int) async
    func reloadTableView() async
}


@available(iOS 13.0.0, *)
final class LogViewController: UIViewController {
    
    private var viewModel: LogViewModelInterface
    
    init(viewModel: LogViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
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
        search.placeholder = Constant.LogViewController.searchBarText.rawValue
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
        viewModel.view = self
        
        Task {
            @MainActor [viewModel] in
            await viewModel.handleViewDidLoad()
            await viewModel.handleFilterLogs(searchBarText: searchBar.text!)
        }   
    }
    
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func updateHeader(filteredLogs: Int, allLogs: Int) {
        headerLabel.text = "Showing \(filteredLogs) of \(allLogs) logs"
    }
    
    @objc private func filterChanged() {
        Task { @MainActor [viewModel] in
            await viewModel.handleFilterChanged(index: filterSegmentedControl.selectedSegmentIndex, searchBarText: searchBar.text ?? "")
        }
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
            title: Constant.LogViewController.clearLogAlertTitle.rawValue,
            message: Constant.LogViewController.clearLogMessage.rawValue,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: Constant.LogViewController.cancelActionTitle.rawValue, style: .cancel))
        alert.addAction(UIAlertAction(title: Constant.LogViewController.clearActionTitle.rawValue, style: .destructive) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [viewModel] in
                await viewModel.handleClearButtonTapped()
            }
        })
        
        present(alert, animated: true)
    }
}


@available(iOS 13.0.0, *)
extension LogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogCell
        cell.configure(with: viewModel.getItem(indexPath: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showLogDetail(viewModel.getItem(indexPath: indexPath))
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
        
        let alert = UIAlertController(title: Constant.LogViewController.logDetailsAlertTitle.rawValue, message: detail, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constant.LogViewController.logCopyActionTitle.rawValue, style: .default) { _ in
            UIPasteboard.general.string = detail
        })
        alert.addAction(UIAlertAction(title: Constant.LogViewController.logDetailCloseActionTitle.rawValue, style: .cancel))
        present(alert, animated: true)
    }
}


@available(iOS 13.0.0, *)
extension LogViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task { @MainActor [viewModel] in
            await viewModel.handleFilterLogs(searchBarText: searchBar.text!)
        }
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

@available(iOS 13.0.0, *)
extension LogViewController: LogViewControllerInterface {
    func setupUI() {
        title = Constant.LogViewController.pageTitle.rawValue
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
        tableView.register(LogCell.self, forCellReuseIdentifier: LogCell.identifier)
        

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
}
