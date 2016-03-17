//
//  LocationModel+CoreDataProperties.swift
//  Pathwayz
//
//  Created by Steven Smith on 8/02/2016.
//  Copyright © 2016 Steven Smith. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LocationModel {

    @NSManaged var lat: NSNumber?
    @NSManaged var long: NSNumber?
    @NSManaged var time: NSDate?
    @NSManaged var speed: NSNumber?

}
