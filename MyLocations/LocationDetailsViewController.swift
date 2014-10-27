//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Ed on 10/27/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit
import CoreLocation

//#####################################################################
// MARK: - Private Global Constants
//         Only a single instance is ever created (to conserve execution time and battery power).
//         The code is run only the very first time the object is needed in the app (a.k.a. lazy loading).
//         "private" constants cannot be used outside of this Swift file.

private let dateFormatter: NSDateFormatter = {
  
  // Using a CLOSURE to create the object and set its properties all at once.
  //   The format for a Closure is:  { /* the closure code goes here */ }
  
  let formatter = NSDateFormatter()
  
  formatter.dateStyle = .MediumStyle
  formatter.timeStyle = .ShortStyle
  
  return formatter
  
  // Using "()" after the Closure to assign the result of the closure code to dateFormatter.
  // Omitting "()" would assign the block of code itself to dateFormatter.
}()

//#####################################################################
class LocationDetailsViewController: UITableViewController {
  
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  //------------------------------------------
  // Location Coordinates and Address
  
  // Contains the latitude and longitude from the CLLocation object received from the location manager. 
  // (These two fields are the only ones required, so there’s no point in sending along the entire CLLocation object.)
  
  // "coordinate" is not an optional because the Tag Location button cannot be tapped unless valid GPS coordinates have been found.
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  
  // This contains address information obtained through reverse geocoding.
  var placemark: CLPlacemark?
  
  //#####################################################################
  // MARK: - Initialization
  
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    descriptionTextView.text = ""
    categoryLabel.text = ""

    latitudeLabel.text  = String(format: "%.8f", coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    
    if let placemark = placemark {
      addressLabel.text = stringFromPlacemark(placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    
    dateLabel.text = formatDate(NSDate())
  }
  //#####################################################################
  // MARK: - Action Methods
  
  @IBAction func done() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  //#####################################################################
  @IBAction func cancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  //#####################################################################
  // MARK: - Formatting
  
  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    // Format the CLPlacemark object into a string.
    
    return "\(placemark.subThoroughfare) \(placemark.thoroughfare), " +
           "\(placemark.locality), " +
           "\(placemark.administrativeArea) \(placemark.postalCode)," +
           "\(placemark.country)"
  }
  //#####################################################################

  func formatDate(date: NSDate) -> String {
    return dateFormatter.stringFromDate(date)
  }
  //#####################################################################
}