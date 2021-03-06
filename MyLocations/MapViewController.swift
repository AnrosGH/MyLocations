//
//  MapViewController.swift
//  MyLocations
//
//  Created by Ed on 11/3/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  //------------------------------------------
  //var managedObjectContext: NSManagedObjectContext!
  //------------------------------------------
  // For use with the Locations button.
  
  // Create a new, empty array for storing Location objects (denoted by "[Location]") and assign it to the "locations" instance variable.
  // This "()" instantiates the array.
  var locations = [Location]()
  //------------------------------------------
  // Set up a "Property Observer" using a "didSet block".
  // The code in the didSet block is performed whenever the variable is assigned a new value.
  
  // As soon as managedObjectContext is given a value – which happens in AppDelegate during app startup – 
  // the didSet block tells the NSNotificationCenter to add an observer for the NSManagedObjectContextObjectsDidChangeNotification.
  // This notification is sent out whenever the data store changes.
  
  var managedObjectContext: NSManagedObjectContext! {
    didSet {
      NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification,
                                                              object: managedObjectContext,
                                                              queue: NSOperationQueue.mainQueue()) { notification in
      
        // Because this particular closure gets called by NSNotificationCenter, an NSNotification object is passed in as the "notification" parameter. 
        // if this notification object was not being used anywhere in the closure, then the parameter could have been written as "{ _ in".
      
        if self.isViewLoaded() {
          
          // CODE REPLACED WITH MORE EFFICIENT CODE BELOW (Exercise on page 218).
          // Fetch all the Location objects again. 
          // This throws away all the old pins and it makes new pins for all the newly fetched Location objects.
          //self.updateLocations()
          
          if let dictionary = notification.userInfo {
            
            // Print out userInfo dictionary in NSNotification object.
            //println(dictionary["inserted"])
            //println(dictionary["deleted"])
            //println(dictionary["updated"])
            
            // NOTE: dictionary["updated"] is not an array of Location objects but an NSSet of Location objects.
            // A set (or NSSet) is like an array but the items inside it don't have a specific order.
            //------------------------------------------
            if let inserted: AnyObject = dictionary["inserted"] {
              let asSet = inserted as NSSet
              let asArray = asSet.allObjects as [Location]
              self.mapView.addAnnotations(asArray)
            }
            //------------------------------------------
            if let deleted: AnyObject = dictionary["deleted"] {
              let asSet = deleted as NSSet
              let asArray = asSet.allObjects as [Location]
              self.mapView.removeAnnotations(asArray)
            }
            //------------------------------------------
            if let updated: AnyObject = dictionary["updated"] {
              let asSet = updated as NSSet
              let asArray = asSet.allObjects as [Location]
              self.mapView.removeAnnotations(asArray)
              self.mapView.addAnnotations(asArray)
            }
          }
        }
      }
    }
  }
  //#####################################################################
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "EditLocation" {
      
      let navigationController = segue.destinationViewController as UINavigationController
      let controller = navigationController.topViewController as LocationDetailsViewController
      controller.managedObjectContext = managedObjectContext
      
      // Get the Location object to edit from the locations array, using the tag property of the sender button as the index into the array.
      let button = sender as UIButton
      let location = locations[button.tag]
      controller.locationToEdit = location
    }
  }
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Fetch the Location objects and show them on the map when the view loads.
    updateLocations()
    
    if !locations.isEmpty {
      // Show the user's locations the first time the user switches to the Map tab.
      showLocations()
    }
  }
  //#####################################################################
  // MARK: - Action Methods
  
  @IBAction func showUser() {
    
    let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
  }
  //#####################################################################

  @IBAction func showLocations() {
    
    // Calculate a reasonable region that fits all the Location objects.
    let region = regionForAnnotations(locations)
    
    // Set the region on the map view.
    mapView.setRegion(region, animated: true)
  }
  //#####################################################################
  // MARK: - My Methods
  
  func updateLocations() {
    
    // Fetch Location objects.
        
    // Set up an NSFetchRequest object to be used for describing which objects will be fetched from the data store.
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = entity
       
    // Fetch the data.
    var error: NSError?
    let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        
    if foundObjects == nil {
      fatalCoreDataError(error)
      return
    }
    //------------------------------------------
    // Add a pin (annotation) for each location on the map.
    
    // Remove pins for old objects.
    mapView.removeAnnotations(locations)
        
    locations = foundObjects as [Location]
    mapView.addAnnotations(locations)
  }
  //#####################################################################
  
  func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
    
    // By looking at the highest and lowest values for the latitude and longitude of all the Location objects, 
    // calculate a region and tell the map view to zoom to that region.
    
    var region: MKCoordinateRegion
    
    switch annotations.count {
      
      case 0:
        // No annotations.  Center the map on the user's current position.
        region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)

      //------------------------------------------
      case 1:
        // Center the map on the one annotation that exists.
        let annotation = annotations[annotations.count - 1]
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
      
      //------------------------------------------
      default:
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
    
        for annotation in annotations {
          topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
          topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
          bottomRightCoord.latitude = min(bottomRightCoord.latitude,annotation.coordinate.latitude)
          bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
        }
    
        let center = CLLocationCoordinate2D( latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                                             longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
    
        let extraSpace = 1.1
        let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                                    longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
    
        region = MKCoordinateRegion(center: center, span: span)
    }
    return mapView.regionThatFits(region)
  }
  //#####################################################################
  
  func showLocationDetails(sender: UIButton) {
    
    // Because the segue isn’t connected to any particular control in the view controller, the segue must be invoked manually.
    // Send along the button object as the sender, so its tag property can be accessed in method prepareForSegue().
    performSegueWithIdentifier("EditLocation", sender: sender)
  }
  //#####################################################################
}
//#####################################################################
// MARK: - Map View Delegate

extension MapViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    
    // Because MKAnnotation is a protocol, there may be other objects apart from the Location object that want to be annotations on the map.  Leave those alone.
    if annotation is Location {
      
      let identifier = "Location"
      var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as MKPinAnnotationView!
      
      if annotationView == nil {
        // A recyclable annotation view is not available, so create a new one.
      
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      
        // Set some properties to configure the look and feel of the annotation view.
        annotationView.enabled = true
        annotationView.canShowCallout = true
        annotationView.animatesDrop = false
        annotationView.pinColor = .Green
        
        // Set the annotation's tint color to half-opaque black to make the dot for the user's current position and (i) button easier to see.
        annotationView.tintColor = UIColor(white: 0.0, alpha: 0.5)
      
        // Create a new UIButton object that looks like a detail disclosure button (a blue circled i). 
        let rightButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
        
        // Use the target-action pattern to hook up the button’s “Touch Up Inside” event with the showLocationDetails() method.
        // The colon in "showLocationDetails:" means the method takes one parameter, usually called "sender", that refers to the control that sent the action message.
        // The colon comes from Objective-C, which is obsessed with colons and square brackets.
        rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: .TouchUpInside)
        
        // Add the button to the annotation view’s accessory view.
        annotationView.rightCalloutAccessoryView = rightButton
      
      //------------------------------------------
      } else {
        annotationView.annotation = annotation
      }
      //------------------------------------------
      // Obtain a reference to the detail disclosure button.
      let button = annotationView.rightCalloutAccessoryView as UIButton
      
      if let index = find(locations, annotation as Location) {
        // Set the button's tag to the index of the Location object in the locations array.
        button.tag = index
      }
      return annotationView
    }
    return nil
  }
  //#####################################################################
}
//#####################################################################
// MARK: - Navigation Bar Delegate

extension MapViewController: UINavigationBarDelegate {
  
  // This delegate method is required to prevent a gap between the top of the screen and the navigation bar. 
  // That happens because, as of iOS 7, the status bar is no longer a separate area but is directly drawn on top of the view controller.
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    // Tell the navigation bar to extend under the status bar area.
    
    return .TopAttached
  }
  //#####################################################################
}

