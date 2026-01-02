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

    func handleViewDidLoad() async
}


@available(iOS 13.0.0, *)
final class LogViewControllerModel {
    weak var view: (any LogViewControllerInterface)?
}

@available(iOS 13.0.0, *)
extension LogViewControllerModel: LogViewModelInterface {
    
    func handleViewDidLoad() async {
        
        await view?.setupUI()
        
    }
}
