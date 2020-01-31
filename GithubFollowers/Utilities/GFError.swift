//
//  GFError.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-07.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import Foundation

enum GFError: String, Error {
    case invalidUsername = "This username created an invalid request. Please try again"
    case unableToComplete = "Unable to complete your request. Please check your internet connection 😅"
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
    
    case unableToFavourite = "There was an error favourting this user. Please try again."
    case alreadyInFavourites = "You have already favourited this user. You must REALLY like them, but you cannot add this user again. Sorry!"
    
    // MARK: SearchVC errors
    case noUserNameEntered = "No username is entered."
}
