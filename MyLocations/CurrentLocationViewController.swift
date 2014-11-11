//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Ed on 10/20/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore  // Framework that provides Core Animation.

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  //------------------------------------------
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  //------------------------------------------
  // Text Labels
  @IBOutlet weak var latitudeTextLabel: UILabel!
  @IBOutlet weak var longitudeTextLabel: UILabel!
  //------------------------------------------
  // Container for Lat/Long Labels and Tag Location Button
  @IBOutlet weak var containerView: UIView!
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
  //------------------------------------------
  // Reverse Geocoding (lat & long to an address)
  let geocoder = CLGeocoder()                // Object that will perform the geocoding.
  var placemark: CLPlacemark?                // Object containing the address results.
  var performingReverseGeocoding = false
  var lastGeocodingError: NSError?
  //------------------------------------------
  // Timeout
  var timer: NSTimer?
  //------------------------------------------
  // Permanent Data Storage
  
  // If managedObjectContext were to be declared without "!", then Swift would demand it be given a value inside an init method.
  // For objects loaded from a storyboard, such as view controllers, the init method is init(coder).
  // Since prepareForSegue() happens after the new view controller is instantiated, and AFTER the call to init(coder). 
  // As a result, inside init(coder) the value for managedObjectContext is indeterminate.
  // Therefore, the managedObjectContext variable must be left nil for a short while until the segue happens, which means it must be an optional.
  var managedObjectContext: NSManagedObjectContext!
  
  //------------------------------------------
  // Logo
  
  // The logo image is actually a button, so that it can be tapped to get started. 
  // The app will show this button when it starts up and when it doesn’t have anything better to display (for example, after pressing Stop and there are no coordinates and no error).
  // The boolean variable, logoVisible, will be used to orchestrate this.
  var logoVisible = false
  
  lazy var logoButton: UIButton = {
    
    // Using a "custom" type UIButton, meaning that it has no title text or other frills.
    let button = UIButton.buttonWithType(.Custom) as UIButton
    
    // Set the button's background image to Logo.png.
    button.setBackgroundImage(UIImage(named: "Logo"), forState: .Normal)
    button.sizeToFit()
    
    // Call method, getLocation(), when tapped.
    button.addTarget(self, action: Selector("getLocation"), forControlEvents: .TouchUpInside)
    
    button.center.x = CGRectGetMidX(self.view.bounds)
    button.center.y = 220
    
    return button
  }()
  //#####################################################################
  // MARK: - Initialization
  
  //#####################################################################
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "TagLocation" {
      
      // The segue does not go directly to LocationDetailViewController but to the navigation controller that embeds LocationDetailViewController.
      // First, set up a constant to represent this UINavigationController object.
      let navigationController = segue.destinationViewController as UINavigationController
      
      // To find the LocationDetailViewController, look at the navigation controller’s topViewController property.
      // This property refers to the screen that is currently active inside the navigation controller.
      let controller = navigationController.topViewController as LocationDetailsViewController
      
      //------------------------------------------
      // Set the properties of LocationDetailViewController.
      
      // Because location is an optional, it needs to be unwrapped before its coordinate property can be accessed. 
      // It’s safe to force unwrap (!) at this point because the Tag Location button that triggers the segue won’t be visible unless a location is found (i.e. not nil).
      controller.coordinate = location!.coordinate
      
      // The placemark variable is also an optional, but so is the placemark property on LocationDetailsViewController.  Therefore, no unwrapping is necessary.
      controller.placemark = placemark
      
      // Dependency Injection
      // Passing on the Managed Object Context onto the LocationDetailsViewController so that not all Classes are directly
      // dependent on the AppDelegate.
      controller.managedObjectContext = managedObjectContext
    }
  }
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
    configureGetButton()
  }
  //#####################################################################
  // MARK: - Action Methods
  
  @IBAction func getLocation() {         // Responds to the "Get My Location" button.

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
    //------------------------------------------------------------------------------------
    // Logo
    
    if logoVisible {
      hideLogoView()
    }
    //------------------------------------------------------------------------------------
    if updatingLocation {
      // The button was pressed while the app is doing location fetching, so stop the fetching.
      stopLocationManager()
      
    } else {
      // The button was pressed while the app is NOT doing location fetching, so start location fetching.
      location = nil
      lastLocationError = nil
      placemark = nil
      lastGeocodingError = nil
      startLocationManager()
    }
    //------------------------------------------
    updateLabels()
    configureGetButton()
  }
  //#####################################################################
  // MARK: - Buttons and Labels

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
      
      //------------------------------------------
      // Make the reverse geocoded address visible to the user.
      // (Reverse geocoding an address only occurs once the app has an accurate location.)
      
      if let placemark = placemark {
        addressLabel.text = stringFromPlacemark(placemark)
        
      } else if performingReverseGeocoding {
        addressLabel.text = "Searching for Address..."
        
      } else if lastGeocodingError != nil {
        addressLabel.text = "Error Finding Address"
        
      } else {
        addressLabel.text = "No Address Found"
      }
      //------------------------------------------
      latitudeTextLabel.hidden = false
      longitudeTextLabel.hidden = false
      
    //------------------------------------------------------------------------------------
    } else {
      // Location does not exist.
      
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.hidden = true
      messageLabel.text = "Tap 'Get My Location' to Start"
      
      //------------------------------------------
      // Error handling - show a status message.
      
      var statusMessage: String
      
      if let error = lastLocationError {
        
        if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
        //if error.domain == kCLErrorDomain && error.code == CLError.Denied.toRaw() {
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
        //statusMessage = "Tap 'Get My Location' to Start"

        // Display the logo instead of a status message.
        statusMessage = ""
        showLogoView()
      }
      
      messageLabel.text = statusMessage
      
      //------------------------------------------
      latitudeTextLabel.hidden = true
      longitudeTextLabel.hidden = true
    }
  }
  //#####################################################################
  
  func configureGetButton() {
    
    let spinnerTag = 1000

    if updatingLocation {
      
      getButton.setTitle("Stop", forState: .Normal)
      
      //--------------------
      // ACTIVITY INDICATOR
      
      if view.viewWithTag(spinnerTag) == nil {
        
        // Create a new UIActivityIndicatorView instance.
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
        
        // Position the spinner view below the message label at the top of the screen.
        spinner.center = messageLabel.center
        spinner.center.y += spinner.bounds.size.height/2 + 15
        spinner.startAnimating()
        spinner.tag = spinnerTag
        
        // Make the spinner visible on the screen.
        containerView.addSubview(spinner)
      }
    //------------------------------------------
    } else {
      
      getButton.setTitle("Get My Location", forState: .Normal)
      
      //--------------------
      // ACTIVITY INDICATOR

      if let spinner = view.viewWithTag(spinnerTag) {
        // Revert the button to its old state by removing the activity indicator view from the screen.
        spinner.removeFromSuperview()
      }
    }
  }
  //#####################################################################
  // MARK: - Logo View
  
  func showLogoView() {
      
    if !logoVisible {
      logoVisible = true
    
      // Hide the container view so the GPS labels are hidden.
      containerView.hidden = true

      view.addSubview(logoButton)
    }
  }
  //#####################################################################
  
  func hideLogoView() {
    
    // Remove the button with the logo.
    //logoVisible = false
    
    // Show the GPS labels.
    //containerView.hidden = false
    //logoButton.removeFromSuperview()
    
    //------------------------------------------
    // Animate hiding the logo instead of using the code above.
    
    if !logoVisible { return }
    
    logoVisible = false
    
    // Create three animations that are played simultaneously.
    
    //------------------------------------------
    // ANIMATION 1
    // Place the containerView (that contains the GPS labels and Tag Location button) outside of the screen (somewhere to the right) and
    // move it to the center of the screen.
    
    containerView.hidden = false
    
    containerView.center.x = view.bounds.size.width * 2
    containerView.center.y = 40 + containerView.bounds.size.height / 2
    
    let centerX = CGRectGetMidX(view.bounds)
    let panelMover = CABasicAnimation(keyPath: "position")
    
    panelMover.removedOnCompletion = false
    panelMover.fillMode = kCAFillModeForwards
    panelMover.duration = 0.6
    panelMover.fromValue = NSValue(CGPoint: containerView.center)
    panelMover.toValue = NSValue(CGPoint: CGPoint(x: centerX, y: containerView.center.y))
    panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    // Since the panelMover animation takes the longest, set a delegate on it so that this view controller can be notified when the entire animation has been completed.
    // (The methods for this delegate are not declared in a protocol, so there is no need to add anything to your class line. 
    //  This is also known as an informal protocol. It’s a holdover from the early days of Objective-C.)
    panelMover.delegate = self
    
    containerView.layer.addAnimation(panelMover, forKey: "panelMover")
    
    //------------------------------------------
    // ANIMATION 2
    // Slide the logo image view off of the screen.
    
    let logoMover = CABasicAnimation(keyPath: "position")
    
    logoMover.removedOnCompletion = false
    logoMover.fillMode = kCAFillModeForwards
    logoMover.duration = 0.5
    logoMover.fromValue = NSValue(CGPoint: logoButton.center)
    logoMover.toValue = NSValue(CGPoint: CGPoint(x: -centerX, y: logoButton.center.y))
    logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    logoButton.layer.addAnimation(logoMover, forKey: "logoMover")
    
    //------------------------------------------
    // ANIMATION 3
    // Rotate the image view around its center giving the impression that it is rolling away.
    
    let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
    
    logoRotator.removedOnCompletion = false
    logoRotator.fillMode = kCAFillModeForwards
    logoRotator.duration = 0.5
    logoRotator.fromValue = 0.0
    logoRotator.toValue = -2 * M_PI
    logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator")
  }
  //#####################################################################
  // MARK: - Informal Protocol for Animation
  
  override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {

    // Clean up after the animations and remove the logo button.
    
    containerView.layer.removeAllAnimations()
    containerView.center.x = view.bounds.size.width / 2
    containerView.center.y = 40 + containerView.bounds.size.height / 2
    logoButton.layer.removeAllAnimations()
    logoButton.removeFromSuperview()
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
      
      //------------------------------------------
      // Set up a timer object that sends the "didTimeOut" message to self after 60 seconds.
      timer = NSTimer.scheduledTimerWithTimeInterval(60,
                                              target: self,
                                            selector: Selector("didTimeOut"),
                                            userInfo: nil,
                                             repeats: false)
    }
  }
  //#####################################################################

  func stopLocationManager() {
    if updatingLocation {
      
      if let timer = timer {
        // Cancel the timer in case the location manager is stopped before the time-out fires.
        // This happens when an accurate enough location is found within one minute after starting or when the user taps the Stop button.
        timer.invalidate()
      }
      //------------------------------------------
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }
  //#####################################################################

  func didTimeOut() {
    // Called after a time period set in method startLocationManager, whether or not a valid location has been obtained 
    // (unless stopLocationManager cancels the timer first).
    
    println("*** Time out")
    
    if location == nil {
      // Still no valid location.
      
      stopLocationManager()
      
      // Create a custom error code.
      lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
      
      // Update the screen.
      updateLabels()
      configureGetButton()
    }
  }
  //#####################################################################
  
  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    // Format a CLPlacemark object into a string.
      
    // subThoroughfare    = house number
    // thoroughfare       = street name
    // locality           = city
    // administrativeArea = state or province
    // postalCode         = zip code or postal code
      
    // "\n" = line break
      
    //------------------------------------------
    var line1 = ""
    //------------------------------------------
    // CHANGING TO USE METHOD addText FROM String+AA.swift INSTEAD OF WITHIN THIS CLASS.
    //line1 = addText(placemark.subThoroughfare, toLine: line1, withSeparator: "")
    //line1 = addText(placemark.thoroughfare,    toLine: line1, withSeparator: " ")
    
    line1.addText(placemark.subThoroughfare)                      // Using the default value for the separator.
    line1.addText(placemark.thoroughfare,    withSeparator: " ")
    
    //------------------------------------------
    var line2 = ""
    //------------------------------------------
    //line2 = addText(placemark.locality,           toLine: line2, withSeparator: "")
    //line2 = addText(placemark.administrativeArea, toLine: line2, withSeparator: " ")
    //line2 = addText(placemark.postalCode,         toLine: line2, withSeparator: " ")
    
    line2.addText(placemark.locality)
    line2.addText(placemark.administrativeArea, withSeparator: " ")
    line2.addText(placemark.postalCode,         withSeparator: " ")
    
    //------------------------------------------
    if line1.isEmpty {
      // There is no text in the line1 string, so add a newline and a space to the end of line2. 
      // This forces the UILabel to always draw two lines of text, even if the second one looks empty (it only has a space).
      return line2 + "\n "
      
    } else {
      return line1 + "\n" + line2
    }
  }
  //#####################################################################
  // MOVED TO THE STRING EXTENSIONS FILE, String+AA.swift.
  /*
  func addText(text: String?, toLine line: String, withSeparator separator: String) -> String {
    // Add text (or nil) to a regular string, with a separator such as a space or comma. 
    // The separator is only used if line isn’t empty.
      
    var result = line
      
    if let text = text {
      // text is NOT nil.
        
      if !line.isEmpty {
        result += separator
      }
      result += text
    }
    return result
  }
  */
  //#####################################################################
  // MARK: - Location Manager Delegate Protocol
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    println("didFailWithError \(error)")
    
    // The error codes used by Core Location have simple integer values. Rather than using the values 0, 1, 2 and so on in your program, 
    // Core Location has given them symbolic names using the CLError enum.  "rawValue" converts a name back to its integer value.
        
    if error.code == CLError.LocationUnknown.rawValue {
    //if error.code == CLError.LocationUnknown.toRaw() {
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
    configureGetButton()
  }
  //#####################################################################

  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    // Since "locations" is cast as an array of type AnyObject, it is necessary to more specifically cast it here.
    let newLocation = locations.last as CLLocation
    println("didUpdateLocations \(newLocation)")
    
    //------------------------------------------------------------------------------------
    // Detect Location Accuracy
        
    // Getting location updates costs a lot of battery power as the device needs to keep its GPS/Wi-Fi/cell radios powered up for this. 
    // This app doesn’t need to ask for GPS coordinates all the time, so it should stop when the location is accurate enough.
        
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      // If the time at which the location object was determined is too long ago (5 seconds in this case), 
      // then this is a "cached" result.  Instead of returning a new location fix, the location manager may initially provide the most
      // recently found location under the assumption that the user might not have moved much since last time.
      // Simply ignore these cached locations if they are too old.
      return
    }
    //------------------------------------------
    if newLocation.horizontalAccuracy < 0 {
        // horizontalAccuracy is less than 0.  Therefore, the measurements are invalid and should be ignored.
        return
    }
    //------------------------------------------
    // Deal with the iPod touch which doesn't have a GPS but only relies on Wi-Fi to determine location which may result in not being able to reach 
    // the location accuracy threshhold.
    
    // Set the distance between the new location and the previous one to a gigantic number in the event no previous location exists.
    var distance = CLLocationDistance(DBL_MAX)

    if let location = location {
      // A previous location exists.  Calculate the distance between the new location and the previous one.
      distance = newLocation.distanceFromLocation(location)
    }
    //------------------------------------------
    // Determine if the new location reading is more useful than the previous one.
        
    // Using a forced unwrap of "location" (via "!").  
    // "location!.horizontalAccuracy > newLocation.horizontalAccuracy" is never preformed (i.e. "Short Circuited") if "location == nil" 
    // because the first condition of the IF statement is true.
        
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      // "location" is nil, so this is the very first location update being received.  Continue.
      // OR
      // The range of accuracy (i.e. 100 m) of the previous reading (location!.horizontalAccuracy) is greater than 
      // the range of accuracy (i.e. 10 m)  of the new reading (newLocation.horizontalAccuracy).
      // In other words, the new reading is more accurate.
      
      lastLocationError = nil  // Clear any previous error messages.
      location = newLocation   // Store the new location object.
      updateLabels()
      
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        // The range of accuracy of the new reading is equal to or better than the threshhold set in method, startLocationManager().
        println("*** We're done!")
        stopLocationManager()
        configureGetButton()
        //--------------------
        if distance > 0 {
          // Force a reverse geocoding for the final location in the event that 
          // the app is currently in the process of performing a reverse geocode on the second-to-last location.
          performingReverseGeocoding = false
      
        // else if the distance between the new location and the previous one = 0, then the reverse geocode of the second-to-last location is sufficient.
        }
      }
      //------------------------------------------
      // Reverse Geocoding
      
      // The app should only perform a single reverse geocoding request at a time.
      
      if !performingReverseGeocoding {
        // The app is NOT performing a reverse geocoding request.
      
        println("*** Going to geocode")
        performingReverseGeocoding = true
      
        // Tell the CLGeocoder object to reverse geocode the location and that the code following "completionHandler:" should be executed
        // as soon as the geocoding is completed.
      
        geocoder.reverseGeocodeLocation(location, completionHandler: {placemarks, error in
          // This is a CLOSURE.  Variables before the "in" keyword are input parameters ("placemarks" and "error").
          // The code is executed after CLGeocoder finds an address or encounters an error.
          // A Closure is used instead of a delegate so that the code 
          // a) is executed asynchronously and
          // b) resides right where it would have been called, which makes the code more compact and easier to read.
      
          // placemarks - will contain an array of CLPlacemark objects that describe the address information.
          // error - contains an error message if something went wrong.
        
          println("*** Found placemarks: \(placemarks), error: \(error)")
          //--------------------
          // Get the placemark object for displaying the address to the user.
      
          // Store the error object for future reference.
          // NOTE: "self" is required inside a Closure, but optional outside a Closure.
          self.lastGeocodingError = error
      
          if error == nil && !placemarks.isEmpty {
            // No errors AND objects exist in the placemarks array.
        
            // Usually there will be only one CLPlacemark object in the array, but it is possible for one location coordinate to refer to more than one address. 
            // This app can only handle one address, so just pick the last object in the placemarks array (which usually is the only one).
        
            // The placemarks array contains objects of type AnyObject. This happens because CLGeocoder was written in Objective-C,
            // which isn’t as expressive as Swift.  Because the placemark instance variable is of type CLPlacemark, 
            // the object must be type cast using the “as” operator, indicating that objects from this array are always going to be CLPlacemark objects.
            // Also, since "placemark" is an optional instance variable, it must be cast as an optional (indicated by "?").
            self.placemark = placemarks.last as? CLPlacemark
            
            // To test Core Data fatal error handling, comment out the line above.
        
          } else {
            // An error occurred during geocoding.
            // Clear the placemark because only the address corresponding to the current location is desired or no address at all - NOT an old address.
            self.placemark = nil
          }
          self.performingReverseGeocoding = false
          self.updateLabels()
        })
      }
    //------------------------------------------
    } else if distance < 1.0 {
      // location is NOT nil AND the distance between the new location and the previous one < 1.0 meter.
      
      // This logic guards against devices that have no GPS and only rely on Wi-Fi, which could result in accuracy readings
      // that never reach the minimum accuracy setting.  For example, an iPod Touch experiment resulted in only a +/- 100 meters accuracy.
      
      // Calculate the time interval between receipt of the new location and the previous one.
      let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)  // Note that "location" is guaranteed NOT to be nil.  Therefore, "!".
        
      if timeInterval > 10 {
        // It has been more than 10 seconds between location updates that are essentially the same.  Assume this is the best coordinate attainable.
          
        println("*** Force done!")
        stopLocationManager()
        updateLabels()
        configureGetButton()
      }
    }
  }
  //#####################################################################
}

