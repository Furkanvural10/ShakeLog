//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 1.01.2026.
//

import UIKit


@available(iOS 13.0, *)
final class LogCell: UITableViewCell {
    
    static let identifier: String = "LogCell"
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(levelLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            iconLabel.widthAnchor.constraint(equalToConstant: 24),
            
            timeLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            levelLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 8),
            levelLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            
            locationLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            locationLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            messageLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with log: LogEntry) {
        iconLabel.text = log.level.icon
        timeLabel.text = log.formattedTimestamp
        levelLabel.text = log.level.name
        levelLabel.textColor = log.level.color
        
        let fileName = (log.file as NSString).lastPathComponent
        locationLabel.text = "\(fileName):\(log.line) • \(log.function)"
        
        messageLabel.text = log.message
    }
}
