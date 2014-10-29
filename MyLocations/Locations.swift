//
//  Locations.swift
//  Locations
//
//  Created by Ed on 10/29/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import Foundation
import CoreData

// Required for placemark.
import CoreLocation

class Locations: NSManagedObject {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDescription: String
    @NSManaged var category: String
  
    @NSManaged var placemark: CLPlacemark?

}
