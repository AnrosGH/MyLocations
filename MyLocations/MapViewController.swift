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
  var managedObjectContext: NSManagedObjectContext!
  //------------------------------------------
  // For use with the Locations button.
  var locations = [Location]()
  
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