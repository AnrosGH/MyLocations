//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Ed on 10/30/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
  
  var managedObjectContext: NSManagedObjectContext!
  //------------------------------------------
  // Create a new, empty array for storing Location objects (denoted by "[Location]") and assign it to the "locations" instance variable.
  // This "()" instantiates the array.
  
  // NOTE1: This is a single-line version of
  //        1) Declaring the array:                                   var locations: [Location]
  //        2) and initializing it in method, required init(coder):   locations = [Location]()
  
  // NOTE2: This also could have been written more verbosely as:      var locations: [Location] = [Location]()
  var locations = [Location]()
  
  //#####################################################################
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    // This method is invoked when the user taps a row in the Locations screen.
    // Allows data to be passed to the new view controller before the new view is displayed.
    
    if segue.identifier == "EditLocation" {
      // Tell ListDetailViewController that the AllListsViewController is now its delegate.
      
      // The segue does not go directly to LocationDetailsViewController but to the navigation controller that embeds it.
      // First, set up a constant to represent this UINavigationController object.
      let navigationController = segue.destinationViewController as UINavigationController
      
      // To find the LocationDetailsViewController, look at the navigation controller’s topViewController property.
      // This property refers to the screen that is currently active inside the navigation controller.
      let controller = navigationController.topViewController as LocationDetailsViewController
      
      // Pass a reference to the ManagedObjectContext object to the LocationDetailsViewController.
      controller.managedObjectContext = managedObjectContext
      
      //------------------------------------------
      // EDIT Mode Setup
      
      // The sender parameter from prepareForSegue(sender) is of type AnyObject, but indexPathForCell() expects a UITableViewCell object instead.
      // Therefore, sender must be more specifically cast to type UITableViewCell.
      
      if let indexPath = tableView.indexPathForCell(sender as UITableViewCell) {
        let location = locations[indexPath.row]
        controller.locationToEdit = location
        
        // Setting LocationDetailsViewController's property, locationToEdit, triggers the didSet code block of its Property Observer for locationToEdit
        // to be executed, which loads all of the LocationDetailsViewController's properties.  
        // Since this prepareForSegue method (and therefore, the didSet code block) get called before LocationDetailsViewController's viewDidLoad() method,
        // all of the up-to-date values are shown to the user in the LocationDetailsViewController's screen.
      }
    }
  }
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //------------------------------------------
    // Ask the managed object context for a list of all Location objects in the data store, sorted by date.
    
    // Set up an NSFetchRequest object to be used for describing which objects will be fetched from the data store.
    let fetchRequest = NSFetchRequest()
    
    // Set the entity to "Location".
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
    fetchRequest.entity = entity
    
    // Sort Locations by date in ascending order.
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Fetch the data.
    var error: NSError?
    let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
    
    if foundObjects == nil {
      fatalCoreDataError(error)
      return
    }
    // Assign the contents of the foundObjects array to the locations instance variable, casting it from an array of AnyObjects to Locations.
    locations = foundObjects as [Location]
    //------------------------------------------
  }
  //#####################################################################
}
//#####################################################################
// MARK: - Table View Data Source

extension LocationsViewController: UITableViewDataSource {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locations.count
  }
  //#####################################################################
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    // Use prototype cells designed in Interface BuilderCreate instead of creating the table view cell in code.
    
    // Get a copy of the prototype cell – either a new one or a recycled one.
    // Type Cast Note:
    //   dequeueReusableCellWithIdentifier() can return nil if there is no cell object to reuse.
    //   When using prototpye cells, however, dequeueReusableCellWithIdentifier() will never return nil so
    //   so a non-optional constant can be type cast using "as LocationCell" (as opposed to "as? LocationCell" for an optional).
    let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as LocationCell
    
    let location = locations[indexPath.row]
    
    //------------------------------------------
/*
    // REMOVED: Using tagged cells was replaced with a custom table view cell subclass, LocationCell.
    
    let descriptionLabel = cell.viewWithTag(100) as UILabel
    descriptionLabel.text = location.locationDescription
    
    let addressLabel = cell.viewWithTag(101) as UILabel
    
    if let placemark = location.placemark {
      addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare)," + "\(placemark.locality)"
    } else {
      addressLabel.text = ""
    }
*/
    // Put the Location object into the table view cell.
    cell.configureForLocation(location)
    //------------------------------------------
    return cell
  }
  //#####################################################################
}

