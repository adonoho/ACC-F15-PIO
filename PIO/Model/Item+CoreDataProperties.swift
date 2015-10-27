//
//  Item+CoreDataProperties.swift
//  PIO
//
//  Created by Andrew Donoho on 10/26/15.
//  Copyright © 2015 Donoho Design Group, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var date: NSDate
    @NSManaged var done: Bool
    @NSManaged var problem: String
    @NSManaged var title: String

}
