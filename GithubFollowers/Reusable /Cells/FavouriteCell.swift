//
//  FavouriteCell.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-29.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit

class FavouriteCell: UITableViewCell {

    static let reuseIdentifier = "favourite-cell-reuse-identifier"
    let avatarImageView = GFAvatarImageView(frame: .zero)
    let usernameLabel = GFTitleLabel(textAlignment: .left, fontSize: 24)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError("") }
    
    private func configure () {
        addSubviews(avatarImageView, usernameLabel)
        accessoryType = .disclosureIndicator
        let inset = CGFloat(12)
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: inset * 2),
            usernameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            usernameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func set(favourite: CDFollower) {
        usernameLabel.text = favourite.login
        NetworkManager.shared.downloadImage(from: favourite.avatarUrl!) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async { self.avatarImageView.image = image }
        }
    }
}
