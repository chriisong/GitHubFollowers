//
//  UIViewController+Ext.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-06.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
    
    func presentGFAlertOnMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = GFAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
    
    func presentGFAlertActionVC(title: String, message: String, buttonTitle: String, buttonAction: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alertVC = GFAlertVC(title: title, message: message, buttonTitle: buttonTitle, buttonAction: buttonAction)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            alertVC.customAction {
                buttonAction()
                self.dismiss(animated: true)
            }
            self.present(alertVC, animated: true)
        }
    }
    
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .formSheet
        safariVC.preferredControlTintColor = .systemGreen
        present(safariVC, animated: true)
    }
}
