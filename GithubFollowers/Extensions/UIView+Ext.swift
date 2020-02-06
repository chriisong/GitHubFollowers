//
//  UIView+Ext.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-02-05.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
}
