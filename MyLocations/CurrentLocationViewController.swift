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
  //------------------------------------------
  // For storing the user's location.
  // (Needs to be an optional because it is possible to NOT have a location.)
  var location: CLLocation?
  //------------------------------------------
  // Location error handling
  var updatingLocation = false
  var lastLocationError: NSError?
  
  //#####################################################################
  // MARK: -
  // MARK: Initialization
  
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
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
    startLocationManager()
    updateLabels()
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
  
  func updateLabels() {
    
    // Using if/let to unwrap "location" because it is an optional.
    // Note that it’s OK for the unwrapped variable to have the same name as the optional – here they are both called location.
    if let location = location {
      // Location exists.
    
      // Latitude and longitude are of type Double, so they need to be converted to strings.
      // String interpolation (latitudeLabel.text = "\(location.coordinate.latitude)") is not being used.
      // A format string is being used instead so that formatting can be applied.
      // ".8" means there will be 8 digits after the decimal point.
    
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      tagButton.hidden = false
      messageLabel.text = ""
    
    //------------------------------------------------------------------------------------
    } else {
      // Location does not exist.
    
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.hidden = true
      messageLabel.text = "Tap 'Get My Location' to Start"
      
      //------------------------------------------
      // Error handling
      
      var statusMessage: String
      
      if let error = lastLocationError {
        //if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
        if error.domain == kCLErrorDomain && error.code == CLError.Denied.toRaw() {
          // The user has not given the app permission to use location services.
          statusMessage = "Location Services Disabled"
        //--------------------
        } else {
          // Probably was not able to get a location fix.
          statusMessage = "Error Getting Location"
        }
      //--------------------
      } else if !CLLocationManager.locationServicesEnabled() {
        // Even if there was no error, it might still be impossible to get location coordinates if the user disabled Location Services 
        // completely on the device (instead of just for this app).
        statusMessage = "Location Services Disabled"
      //--------------------
      } else if updatingLocation {
        // Everything is fine, but the first location object has not yet been received.
        statusMessage = "Searching..."
      //--------------------
      } else {
        statusMessage = "Tap 'Get My Location' to Start"
      }
      
      messageLabel.text = statusMessage
    }
  }
  //#####################################################################

  func startLocationManager() {
        
    if CLLocationManager.locationServicesEnabled() {
      // Location services are enabled.
        
      // Set the location manager delegate property to this view controller.
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
      // The new CLLocationManager object doesn’t give out GPS coordinates right away.
      // To begin receiving coordinates requires a call to its startUpdatingLocation() method first.
      // Continuously receiving GPS coordinates requires a lot of power and will quickly drain the battery.
      // The location manager will be turned on only when a location is needed and turned off again once a usable location has been received.
      locationManager.startUpdatingLocation()
        
      updatingLocation = true
    }
  }
  //#####################################################################

  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }
  //#####################################################################
  // MARK: - Location Manager Delegate Protocol
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    println("didFailWithError \(error)")
    
    // The error codes used by Core Location have simple integer values. Rather than using the values 0, 1, 2 and so on in your program, 
    // Core Location has given them symbolic names using the CLError enum.  "rawValue" converts a name back to its integer value.
        
    //if error.code == CLError.LocationUnknown.rawValue {
    if error.code == CLError.LocationUnknown.toRaw() {
      // The CLError.LocationUnknown error means the location manager was unable to obtain a location right now,
      // but that doesn’t mean all is lost. It might just need another second or so to get an uplink to the GPS satellite.
      // In the mean time it’s letting you know that for now it could not get any location information.
      // Simply keep trying until a location is found or a more serious error is received.
      return
    }
    // Store the error object.
    lastLocationError = error
        
    stopLocationManager()
    updateLabels()
  }
  //#####################################################################

  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    let newLocation = locations.last as CLLocation
    println("didUpdateLocations \(newLocation)")
    
    //------------------------------------------
    // If the location was previously unobtainable (i.e., an error occurred), but then a valid location is obtained, then the error code needs to be cleared.
    lastLocationError = nil
        
    // Store the CLLocation object obtained from the location manager.
    location = newLocation
    updateLabels()
  }
  //#####################################################################
}

