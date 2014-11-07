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
  
  //------------------------------------------
  @NSManaged var photoID: NSNumber?
  
  // Computed Properties
  
  var hasPhoto: Bool {
    
    println("PhotoID is \(photoID)")
    
    return photoID != nil
  }
  //--------------------
  var photoPath: String {
    
    // An assertion is a special debugging tool that is used to check that the code is always does something valid.
    // Assertions are usually enabled only while developing and testing an app and disabled when the final build of the app is uploaded to the App Store.
    // If the app were to ask a Location object for its photoPath without having given it a valid photoID earlier, then the app will crash with the message, “No photo ID set”.
    assert(photoID != nil, "No photo ID set")
    
    let filename = "Photo-\(photoID!.integerValue).jpg"
    return applicationDocumentsDirectory.stringByAppendingPathComponent(filename)
  }
  //--------------------
  var photoImage: UIImage? {
      // Return a UIImage by loading the image file.
      return UIImage(contentsOfFile: photoPath)
  }
  //#####################################################################
  // MARK: - MKAnnotation Protocol
  
  // Implementing this Protocol allows a Location object to be seen as an annotation so that it can be placed on a map view.
  
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
  // MARK: - Photos
  
  // Class methods do not require a Location object to call them.  They can be called anytime from anywhere.
  
  class func nextPhotoID() -> Int {
    // Put a simple integer in NSUserDefaults and update it every time the app asks for a new ID.
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let currentID = userDefaults.integerForKey("PhotoID")
    userDefaults.setInteger(currentID + 1, forKey: "PhotoID")
    userDefaults.synchronize()
    return currentID
  }
  //#####################################################################
}
