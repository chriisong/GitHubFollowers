//
//  Date+Ext.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-24.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import Foundation

extension Date {
    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        return dateFormatter.string(from: self)
    }
    
    
}
