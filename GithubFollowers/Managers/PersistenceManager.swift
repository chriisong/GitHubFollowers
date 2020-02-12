//
//  PersistenceManager.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-29.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import CoreData
import Foundation


enum PersistenceActionType {
    case add, remove
}

enum Keys { static let favourites = "favourites" }

enum PersistenceManager {
    static func updateWith(favourite: Follower, actionType: PersistenceActionType, completionHandler: @escaping (GFError?) -> Void) {
        fetchFavourites { result in
            switch result {
            case .success(var favourites):

                switch actionType {
                case .add:
                    guard !favourites.contains(favourite) else {
                        completionHandler(.alreadyInFavourites)
                        return
                    }
                    favourites.append(favourite)
                case .remove:
                    favourites.removeAll { $0.login == favourite.login }
                }
                completionHandler(save(favourites: favourites))
            case .failure(let error):
                completionHandler(error)
            }
        }
    }
    
    static private let defaults = UserDefaults.standard
    
    static func fetchFavourites(completionHandler: @escaping (Result<[Follower], GFError>) -> Void) {
        guard let favouritesData = defaults.object(forKey: Keys.favourites) as? Data else {
            completionHandler(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()

            let favourites = try decoder.decode([Follower].self, from: favouritesData)
            completionHandler(.success(favourites))
        } catch {
            completionHandler(.failure(.unableToFavourite))
        }
    }
    
    static func save(favourites: [Follower]) -> GFError? {
        do {
            let encoder = JSONEncoder()
            let encodedFavourites = try encoder.encode(favourites)
            defaults.set(encodedFavourites, forKey: Keys.favourites)
            return nil
        } catch {
            return .unableToFavourite
        }
    }
}
