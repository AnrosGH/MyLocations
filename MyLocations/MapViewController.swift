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
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Fetch the Location objects and show them on the map when the view loads.
    updateLocations()
  }
  //#####################################################################
  // MARK: - Action Methods
  
  @IBAction func showUser() {
    
    let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
  }
  //#####################################################################

  @IBAction func showLocations() {
      
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
}
//#####################################################################

extension MapViewController: MKMapViewDelegate {
}