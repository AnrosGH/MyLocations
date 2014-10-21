//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Ed on 10/20/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  //------------------------------------------
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  //------------------------------------------
  // The CLLocationManager is the object that will provide GPS coordinates. 
  // Using let, not a variable (var). Its value will never have to change once a location manager object has been created.
  let locationManager = CLLocationManager()
  
  //#####################################################################
  // MARK: -
  // MARK: Initialization
  
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  //#####################################################################
  // MARK: - Action Methods
  
  @IBAction func getLocation() {

    // Ask for permission to use the user's location.
    
    let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
    
    if authStatus == .NotDetermined {
      // The current authorization status is not determined (i.e., the app has not yet asked for permission).
      
      // This allows the app to get location updates while it is open and the user is interacting with it.
      // NOTE: "Always" authorization permits the app to check the user's location even when it is NOT active.
      locationManager.requestWhenInUseAuthorization()
      return
    }
    //------------------------------------------
    // Show an alert that encourages the user to enable location services.
    if authStatus == .Denied || authStatus == .Restricted {
      // The authorization status is denied or restricted.
      showLocationServicesDeniedAlert()
      return
    }
    //------------------------------------------
    // Set the location manager delegate property to this view controller.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    
    // The new CLLocationManager object doesn’t give out GPS coordinates right away. 
    // To begin receiving coordinates requires a call to its startUpdatingLocation() method first.
    // Continuously receiving GPS coordinates requires a lot of power and will quickly drain the battery. 
    // The location manager will be turned on only when a location is needed and turned off again once a usable location has been received.
    locationManager.startUpdatingLocation()
  }
  //#####################################################################
  // MARK: - Location Services
  
  func showLocationServicesDeniedAlert() {
    // This pops up an alert that encourages the user to enable location services.
    
    let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    presentViewController(alert, animated: true, completion: nil)
    alert.addAction(okAction)
  }
  //#####################################################################
  // MARK: - Location Manager Delegate Protocol
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("didFailWithError \(error)")
  }
  //#####################################################################

  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    let newLocation = locations.last as CLLocation
    println("didUpdateLocations \(newLocation)")
  }
  //#####################################################################
}

