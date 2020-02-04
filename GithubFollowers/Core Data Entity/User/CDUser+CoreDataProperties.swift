//
//  CDUser+CoreDataProperties.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-02-03.
//  Copyright © 2020 Chris Song. All rights reserved.
//
//

import Foundation
import CoreData


extension CDUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var bio: String?
    @NSManaged public var followers: Int64
    @NSManaged public var following: Int64
    @NSManaged public var htmlUrl: String
    @NSManaged public var location: String?
    @NSManaged public var login: String
    @NSManaged public var name: String?
    @NSManaged public var publicGists: Int64
    @NSManaged public var publicRepos: Int64
    @NSManaged public var createdAt: Date?

}
