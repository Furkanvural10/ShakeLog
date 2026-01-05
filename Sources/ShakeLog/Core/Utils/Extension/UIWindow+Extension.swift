//
//  File.swift
//  ShakeLog
//
//  Created by furkan vural on 16.12.2025.
//

import Foundation
import UIKit
import SwiftUI

extension UIWindow {
    
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if #available(iOS 13.0.0, *) {
                #if DEBUG
                showLogViewer()
                #endif
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @available(iOS 13.0.0, *)
    private func showLogViewer() {
        guard let topVC = topViewController() else { return }
        
        if topVC is LogViewController || topVC is UINavigationController {
            if let navVC = topVC as? UINavigationController,
               navVC.topViewController is LogViewController {
                return
            }
        }
        
        
        if #available(iOS 14.0, *) {
            if let presentedVC = topVC.presentedViewController as? UIHostingController<LogView> {
                return
            }
        } else {
            // Fallback on earlier versions
        }
        
        switch ShakeLog.config.presentationMode {
        case .uiKit:
            let viewModel: LogViewModelInterface = LogViewControllerModel()
            let logVC = LogViewController(viewModel: viewModel)
            let navVC = UINavigationController(rootViewController: logVC)
            navVC.modalPresentationStyle = .fullScreen
            topVC.present(navVC, animated: true)
            
        case .swiftUI:
            if #available(iOS 14.0, *) {
                let logView = LogView()
                let hostingController = UIHostingController(rootView: logView)
                hostingController.modalPresentationStyle = .fullScreen
                topVC.present(hostingController, animated: true)
            } else {
                let alert = UIAlertController(
                    title: "ShakeLog Error",
                    message: "SwiftUI presentation requires iOS 13.0 or newer.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                topVC.present(alert, animated: true)
            }
        }
    }
    
    private func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? rootViewController
        
        guard let base else { return nil }
        
        if let nav = base as? UINavigationController {
            if let visible = nav.visibleViewController {
                return topViewController(base: visible)
            }
            return nav
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
            return tab
        }
        
        if let presented = base.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
