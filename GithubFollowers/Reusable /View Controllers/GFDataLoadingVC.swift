//
//  GFDataLoadingVC.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-02-03.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit

class GFDataLoadingVC: UIViewController {
    var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        UIView.animate(withDuration: 0.25) { self.containerView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.containerView.removeFromSuperview()
            self.containerView = nil
        }
    }
    
    func showEmptyStateView(with message: String, in view: UIView, tag: Int) {
        let emptyStateView = GFEmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        emptyStateView.tag = tag
        view.addSubview(emptyStateView)
    }
    
    func removeEmptyStateView(in view: UIView, tag: Int) {
        if let viewWithTage = view.viewWithTag(tag) {
            viewWithTage.removeFromSuperview()
        }
    }

}
