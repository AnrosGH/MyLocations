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
    
    if !locations.isEmpty {
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
}
//#####################################################################

extension MapViewController: MKMapViewDelegate {
}