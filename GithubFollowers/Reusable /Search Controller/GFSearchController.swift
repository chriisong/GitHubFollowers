//
//  GFSearchController.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-30.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit

class GFSearchController: UISearchController {
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
    }
    
    init(placeHolder: String, textFieldBackgroundColor: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.searchBar.placeholder = placeHolder
        self.obscuresBackgroundDuringPresentation = false
        self.searchBar.searchTextField.backgroundColor = textFieldBackgroundColor
        self.definesPresentationContext = false
        self.hidesNavigationBarDuringPresentation = false
    }
    
    required init?(coder: NSCoder) { fatalError("") }
}
