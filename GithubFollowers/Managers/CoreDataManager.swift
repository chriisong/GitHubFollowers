//
//  CoreDataManager.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-29.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var follower: CDFollower!
    private var followerFetchRequestController: NSFetchedResultsController<CDFollower>!
    
    func saveToFavourites(favourite: Follower) -> GFError? {
        if follower == nil {
            follower = (NSEntityDescription.insertNewObject(forEntityName: CDFollower.entityName, into: CoreDataManager.shared.viewContext) as! CDFollower)
        }
        follower.login = favourite.login
        follower.avatarUrl = favourite.avatarUrl
        
        do {
            try CoreDataManager.shared.viewContext.save()
            return nil
        } catch {
            print(error.localizedDescription)
            return .unableToFavourite
        }
    }
   
    func removeFromFavourites(favourite: Follower) -> GFError? {
        configureFetchedResultsController()
        guard let fetchedFavourites = followerFetchRequestController.fetchedObjects else { return .invalidData }
        do {
            for fetchedFavourite in fetchedFavourites {
                if fetchedFavourite.login == favourite.login {
                    CoreDataManager.shared.viewContext.delete(fetchedFavourite)
                }
            }
            try CoreDataManager.shared.viewContext.save()
            return nil
        } catch {
            print(error.localizedDescription)
            return .invalidData
        }
    }
    
    func updateWith(favourite: Follower, actionType: PersistenceActionType, completionHandler: @escaping (GFError?) -> Void) {
        configureFetchedResultsController()
        switch actionType {
        case .add:
            guard let favourites = followerFetchRequestController.fetchedObjects else { return }
            for fetchedFavourite in favourites {
                if fetchedFavourite.login == favourite.login {
                    completionHandler(.alreadyInFavourites)
                    return
                }
            }
            completionHandler(CoreDataManager().saveToFavourites(favourite: favourite))
            
        case .remove:
            completionHandler(CoreDataManager().removeFromFavourites(favourite: favourite))
        }
    }
    
    private func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest<CDFollower>(entityName: CDFollower.entityName)
        let sort = NSSortDescriptor(key: "login", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        followerFetchRequestController = NSFetchedResultsController<CDFollower>(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try followerFetchRequestController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
}
