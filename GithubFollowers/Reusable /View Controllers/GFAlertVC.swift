//
//  GFAlertVC.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-06.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit

class GFAlertVC: UIViewController {
    
    // TODO: Make Reusable Alert Container View
    let containerView = GFAlertContainerView()
    let titleLabel = GFTitleLabel(textAlignment: .center, fontSize: 20)
    let messageLabel = GFBodyLabel(textAlignment: .center)
    
    let dismissButton = GFButton(backgroundColor: .systemRed, title: "OK")
    let actionButton = GFButton(backgroundColor: .systemIndigo, title: "OK")
    
    private var alertTitle: String?
    private var message: String?
    private var buttonTitle: String?
    private var buttonAction: (() -> Void)?
    private var isAlertActionVC = false
    
    let inset: CGFloat = 20
    
    init(title: String, message: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
    }
    
    init(title: String, message: String, buttonTitle: String, buttonAction: @escaping() -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.isAlertActionVC = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        
        configureContainerView()
        configureTitleLabel()
        configureActionButton()
        configureBodyLabel()
    }
    
    private func configureContainerView() {
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    private func configureTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.text = alertTitle ?? "Something went wrong here"
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: inset),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -inset),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func configureActionButton() {
        if isAlertActionVC {
            containerView.addSubview(dismissButton)
            containerView.addSubview(actionButton)
            dismissButton.setTitle("Cancel", for: .normal)
            actionButton.setTitle(buttonTitle ?? "OK", for: .normal)
            dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: inset),
                actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -inset),
                actionButton.heightAnchor.constraint(equalToConstant: 44),
                actionButton.trailingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -inset),
                
                dismissButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: inset),
                dismissButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -inset),
                dismissButton.heightAnchor.constraint(equalToConstant: 44),
                dismissButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -inset)
            ])
        } else {
            containerView.addSubview(dismissButton)
            dismissButton.setTitle(buttonTitle ?? "OK", for: .normal)
            dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                dismissButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -inset),
                dismissButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: inset),
                dismissButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -inset),
                dismissButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    private func configureBodyLabel() {
        containerView.addSubview(messageLabel)
        messageLabel.text = message ?? "Unable to complete request"
        messageLabel.numberOfLines = 4
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: inset),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -inset),
            messageLabel.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: -12)
        ])
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
    public func customAction(action: @escaping () -> Void) {
        self.buttonAction = action
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    @objc func actionButtonTapped() {
        buttonAction?()
    }
}
