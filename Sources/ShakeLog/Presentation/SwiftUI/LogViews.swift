//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 1.01.2026.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
public struct LogView: View {
    @StateObject private var viewModel = LogViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List(viewModel.logs, id: \.timestamp) { log in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(log.level.icon)
                        Text(log.level.name.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(color(for: log.level))
                        Spacer()
                        Text(log.formattedTimestamp)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(log.message)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(nil)
                    
                    HStack {
                        Text((log.file as NSString).lastPathComponent)
                        Text(":")
                        Text("\(log.line)")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationBarTitle("Logs")
            .navigationBarItems(
                leading: Button("Clear") {
                    viewModel.clearLogs()
                },
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func color(for level: LogLevel) -> Color {
        switch level {
        case .verbose: return .gray
        case .debug: return .blue
        case .info: return .green
        case .warning: return .orange
        case .error: return .red
        case .critical: return .purple
        }
    }
}
