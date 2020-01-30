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

enum Keys {
    static let favourites = "favourites"
}

enum PersistenceManager {
    static func updateWith(favourite: Follower, actionType: PersistenceActionType, completionHandler: @escaping (GFError?) -> Void) {
        fetchFavourites { result in
            switch result {
            case .success(let favourites):
                var fetchedFavourites = favourites

                switch actionType {
                case .add:
                    guard !fetchedFavourites.contains(favourite) else {
                        completionHandler(.alreadyInFavourites)
                        return
                    }
                    fetchedFavourites.append(favourite)
                case .remove:
                    fetchedFavourites.removeAll { $0.login == favourite.login }
                }
                completionHandler(save(favourites: fetchedFavourites))
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
