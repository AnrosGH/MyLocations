//
//  Locations.swift
//  Locations
//
//  Created by Ed on 10/29/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import Foundation
import CoreData
import MapKit

// Required for placemark.
import CoreLocation

class Location: NSManagedObject, MKAnnotation {

  @NSManaged var latitude: Double
  @NSManaged var longitude: Double
  @NSManaged var date: NSDate
  @NSManaged var locationDescription: String
  @NSManaged var category: String
  
  @NSManaged var placemark: CLPlacemark?
  
  //#####################################################################
  // MARK: - MKAnnotation Protocol
  
  // Read-only Computed Properties
  // Whenever one of these properties is accessed, the logic from their code block is performed.
  
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }
  //------------------------------------------

  var title: String! {
    if locationDescription.isEmpty {
      return "(No Description)"
    } else {
      return locationDescription
    }
  }
  //------------------------------------------

  var subtitle: String! {
    return category
  }
  //#####################################################################
}
