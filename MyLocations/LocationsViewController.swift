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
  //var locations = [Location]()
  //------------------------------------------
  // Set up an NSFetchedResultsController instead of storing results in array "locations".
  
  // Using a lazy initialization pattern with a closure to that the object gets allocated when it is first used which speeds up app start-up and saves memory.
  
  lazy var fetchedResultsController: NSFetchedResultsController = {
    
    // Ask the managed object context for a list of all Location objects in the data store, sorted by date.
    
    // Set up an NSFetchRequest object to be used for describing which objects will be fetched from the data store.
    let fetchRequest = NSFetchRequest()
    
    // Set the entity to "Location".
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entity
    
    // Sort Locations by date in ascending order.
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Specify the number of objects that will be fetched at a time.
    fetchRequest.fetchBatchSize = 20
    
    // Create the fetchedResultsController
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: self.managedObjectContext,                 // "self" is required since this is inside a Closure.
      sectionNameKeyPath: nil,
      cacheName: "Locations")
    
    // Make this view controller the NSFetchedResultsController delegate so that it is informed that objects have been changed, added, or deleted and the table can be updated.
    fetchedResultsController.delegate = self
    
    return fetchedResultsController
    
    // Using "()" after the Closure to assign the result of the closure code to fetchedResultsController.
    // Omitting "()" would assign the block of code itself to fetchedResultsController.
  }()
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
        //let location = locations[indexPath.row]
        // Instead of looking into the locations array, ask the fetchedResultsController for the object at the requested index-path.
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
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
/*
    THIS CODE MOVED TO THE LAZY INITIALIZATION OF VARIABLE fetchedResultsController.
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
*/
    //--------------------
    // FIX FOR iOS 7 & 8 BUG.
    // Clear out the cache of the NSFetchedResultsController.
    NSFetchedResultsController.deleteCacheWithName("Locations")
    //------------------------------------------
    // Perform an initial fetch from the database of Location objects.
    performFetch()
    //------------------------------------------
    // In addition to swipe-to-delete enabled by implementing UITableView Data Source Protocol method, tableview:commitEditingStyle:forRowAtIndexPath,
    // Add an Edit button in the in the navigation bar that triggers an altermate mode for deleting (and sometimes moving) rows.
    navigationItem.rightBarButtonItem = editButtonItem()
  }
  //#####################################################################
  // MARK: - Core Data
  
  func performFetch() {

    var error: NSError?
      
    if !fetchedResultsController.performFetch(&error) {
      fatalCoreDataError(error)
    }
  }
  //#####################################################################
  
  deinit {
    // This method is invoked when the view controller is destroyed.
      
    // Explicitly set the delegate to nil when the NSFetchedResultsController is no longer needed to avoid getting any more notifications that were still pending.
    fetchedResultsController.delegate = nil
  }
  //#####################################################################
}
//#####################################################################
// MARK: - Table View Data Source

extension LocationsViewController: UITableViewDataSource {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //return locations.count
    
    let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    
    return sectionInfo.numberOfObjects
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
    
    //let location = locations[indexPath.row]
    // Instead of looking into the locations array, ask the fetchedResultsController for the object at the requested index-path.
    let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
    
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
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    // Implementing this optional protocol function enables swipe-to-delete.
    
    if editingStyle == .Delete {
      
      // Get the Location object from the selected row.
      let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
      
      // Ask the managed object context to delete the object from the scratch pad.
      // This will trigger the NSFetchedResultsController to send a notification to the delegate (NSFetchedResultsChangeDelete), 
      // which then removes the corresponding row from the table.
      managedObjectContext.deleteObject(location)
      
      var error: NSError?
      
      if !managedObjectContext.save(&error) {
        fatalCoreDataError(error)
      }
    }
  }
  //#####################################################################
}
//#####################################################################
// MARK: - Fetched Results Controller Delegate

extension LocationsViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    println("*** controllerWillChangeContent")
    tableView.beginUpdates()
  }
  //#####################################################################
  
  func controller(controller: NSFetchedResultsController,
                  didChangeObject anObject: AnyObject,
                  atIndexPath indexPath: NSIndexPath?,
                  forChangeType type: NSFetchedResultsChangeType,
                  newIndexPath: NSIndexPath?) {
                    
    switch type {
                    
      case .Insert:
        println("*** NSFetchedResultsChangeInsert (object)")
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                    
      case .Delete:
        println("*** NSFetchedResultsChangeDelete (object)")
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                    
      case .Update:
        println("*** NSFetchedResultsChangeUpdate (object)")
      
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as LocationCell
        let location = controller.objectAtIndexPath(indexPath!) as Location
      
        cell.configureForLocation(location)
                    
      case .Move:
        println("*** NSFetchedResultsChangeMove (object)")
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    }
  }
  //#####################################################################
  
  func controller(controller: NSFetchedResultsController,
                  didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                  atIndex sectionIndex: Int,
                  forChangeType type: NSFetchedResultsChangeType) {
        
    switch type {
        
      case .Insert:
        println("*** NSFetchedResultsChangeInsert (section)")
        tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
          
      case .Delete:
        println("*** NSFetchedResultsChangeDelete (section)")
        tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      
      case .Update:
        println("*** NSFetchedResultsChangeUpdate (section)")
          
      case .Move:
        println("*** NSFetchedResultsChangeMove (section)")
    }
  }
  //#####################################################################
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    println("*** controllerDidChangeContent")
    tableView.endUpdates()
  }
  //#####################################################################
}


