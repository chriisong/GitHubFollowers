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
    private var _user: CDUser!
    private var followerFetchRequestController: NSFetchedResultsController<CDFollower>!
    var userFetchRequestController: NSFetchedResultsController<CDUser>!
    
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
    
    func retrieveUserData(username: String) -> CDUser {
        test(predicate: username)
        guard let fetchedUsername = userFetchRequestController.fetchedObjects?.last else { fatalError("") }
        return fetchedUsername
    }
    
    func saveToUserAndRetreive(user: User, completed: @escaping((CDUser) -> Void)) {
        if _user == nil {
            _user = (NSEntityDescription.insertNewObject(forEntityName: CDUser.entityName, into: CoreDataManager.shared.viewContext) as! CDUser)
        }
        
        _user.login = user.login
        _user.avatarUrl = user.avatarUrl
        _user.name = user.name
        _user.location = user.location
        _user.bio = user.bio
        _user.publicRepos = Int64(user.publicRepos)
        _user.publicGists = Int64(user.publicGists)
        _user.htmlUrl = user.htmlUrl
        _user.following = Int64(user.following)
        _user.followers = Int64(user.followers)
        _user.createdAt = user.createdAt
        
        if CoreDataManager.shared.viewContext.hasChanges {
            do {
                try CoreDataManager.shared.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        completed(_user)
    }
    
    func saveToUser(user: User) {
        if _user == nil {
            _user = (NSEntityDescription.insertNewObject(forEntityName: CDUser.entityName, into: CoreDataManager.shared.viewContext) as! CDUser)
        }

        _user.login = user.login
        _user.avatarUrl = user.avatarUrl
        _user.name = user.name
        _user.location = user.location
        _user.bio = user.bio
        _user.publicRepos = Int64(user.publicRepos)
        _user.publicGists = Int64(user.publicGists)
        _user.htmlUrl = user.htmlUrl
        _user.following = Int64(user.following)
        _user.followers = Int64(user.followers)
        _user.createdAt = user.createdAt

        if CoreDataManager.shared.viewContext.hasChanges {
            do {
                try CoreDataManager.shared.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
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
    
     func configureFetchedResultsController() {
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
    func test(predicate: String) {
        let fetchRequest = NSFetchRequest<CDUser>(entityName: CDUser.entityName)
        let sort = NSSortDescriptor(key: "login", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        fetchRequest.predicate = NSPredicate(format: "login == %@", predicate)
        
        userFetchRequestController = NSFetchedResultsController<CDUser>(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try userFetchRequestController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
     func configureUserFetchedResultsController() {
        let fetchRequest = NSFetchRequest<CDUser>(entityName: CDUser.entityName)
        let sort = NSSortDescriptor(key: "login", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        userFetchRequestController = NSFetchedResultsController<CDUser>(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try userFetchRequestController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func checkForRedudantUser(username: String) -> Bool {
        configureUserFetchedResultsController()
        guard let savedUsers = userFetchRequestController.fetchedObjects else { fatalError("") }

        let check = savedUsers.contains { savedUser in
            if savedUser.login == username {
                return true
            } else {
                return false
            }
        }
        return check
    }
}
