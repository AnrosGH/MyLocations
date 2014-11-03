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
}
//#####################################################################

extension MapViewController: MKMapViewDelegate {
}