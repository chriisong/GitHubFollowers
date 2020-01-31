//
//  CDFollower+CoreDataProperties.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-29.
//  Copyright © 2020 Chris Song. All rights reserved.
//
//

import Foundation
import CoreData


extension CDFollower {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFollower> {
        return NSFetchRequest<CDFollower>(entityName: "CDFollower")
    }

    @NSManaged public var login: String
    @NSManaged public var avatarUrl: String?

}
