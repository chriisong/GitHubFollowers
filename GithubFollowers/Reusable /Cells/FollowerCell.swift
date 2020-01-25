//
//  FollowerCell.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-07.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit

class FollowerCell: UICollectionViewCell {
    static let reuseIdentifier = "Follower-Cell"
    
    let avatarImageView = GFAvatarImageView(frame: .zero)
    let usernameLabel = GFTitleLabel(textAlignment: .center, fontSize: 16)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    func set(follower: Follower) {
        usernameLabel.text = follower.login
        avatarImageView.downloadImage(from: follower.avatarUrl)
    }
    
    private func configure() {
        addSubview(avatarImageView)
        addSubview(usernameLabel)
        
        let inset = CGFloat(8)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            usernameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
}
