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
  //------------------------------------------
  // Description Text View
  var descriptionText = ""
  
  //#####################################################################
  // MARK: - Initialization
  
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    descriptionTextView.text = descriptionText
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
    // Test the descriptionText variable.
    println("Description '\(descriptionText)'")
      
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
    //   StreetNumber StreetName, City, State  Zip Code, Country
    
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
//#####################################################################
// MARK: -
// MARK: Table View Delegate

extension LocationDetailsViewController: UITableViewDelegate {
      
  //#####################################################################
      
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            
    if indexPath.section == 0 && indexPath.row == 0 {
      // Set the height of the Description Cell.
      return 88
            
    //------------------------------------------
    } else if indexPath.section == 2 && indexPath.row == 2 {
      // Set the height of the Address Cell.
      // The cell height may be anywhere from one line of text to several, depending on how big the address string is.
            
      // frame property - a CGRect that describes the position and size of a view.
      // CGRect         - a struct that describes a rectangle with an origin made up of a CGPoint value (X, Y), and a CGSize value for width and height.
            
      // frame  = position of a rectangle with respect to it's superview.
      // bounds = position of a rectangle with respect to the frame.
            
      // Change the width of the label to be 115 points less than the width of the screen and set the height to be excessively high.
      // Because the frame property is being changed, the multi-line UILabel (the text for which was set in viewDidLoad()) 
      // will now word-wrap the text to fit the requested width.
      addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            
      // Now that the label has word-wrapped its contents, size the label to fit its contents. 
      // (Same as "Editor > Size to Fit Content" in the storyboard.)
      addressLabel.sizeToFit()
            
      // The call to sizeToFit() removed any spare space to the right and bottom of the label. It may also have changed the width 
      // so that the text fits inside the label as snugly as possible.
      // Because of these possible changes, the X-position of the label may no longer be correct.
      // A “detail” label like this should be placed against the right edge of the screen with a 15-point margin between them. 
      // That’s done by changing the frame’s origin.x position.
      addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            
      // Now that the label's height is set, add a margin (10 points on top and bottom).
      return addressLabel.frame.size.height + 20
            
    //------------------------------------------
    } else {
      // All other cells have a standard height.
      return 44
    }
  }
  //#####################################################################
}
//#####################################################################
// MARK: -
// MARK: Text View Delegate

extension LocationDetailsViewController: UITextViewDelegate {
        
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
              
    // Update the contents of the descriptionText instance variable whenever the user types into the text view.
    // In order to use the stringByReplacingCharactersInRange() method, the textView's text must first be converted to an NSString object. 
    descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
              
    return true
  }
  //#####################################################################
  
  func textViewDidEndEditing(textView: UITextView) {
    descriptionText = textView.text
  }
  //#####################################################################
}

