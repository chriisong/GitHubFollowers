//
//  GFAvatarImageView.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-07.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit

class GFAvatarImageView: UIImageView {
    let cache = NetworkManager.shared.cache
    
    let placeholderImage = Images.placeholderImage
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }

}
