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
  //------------------------------------------
  // Temporarily store the chosen category.
  var categoryName = "No Category"
  
  //#####################################################################
  // MARK: - Initialization
  
  //#####################################################################
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "PickCategory" {
      // The segue’s destinationViewController is the CategoryPickerViewController, not a UINavigationController.
      
      // "destinationViewController" must be cast from its generic type (AnyObject) to the specific type used in this app
      // (CategoryPickerViewController) before any of its properties can be accessed.
      let controller = segue.destinationViewController as CategoryPickerViewController
      
      controller.selectedCategoryName = categoryName
    }
  }
  //#####################################################################
  // MARK: - Unwind Segues
  
  // An unwind segue is an action method that takes a UIStoryboardSegue parameter.
  
  @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
    // A storyboard connection was made from the prototype cell in the CategoryPickerViewController to that view controller's Exit button
    // to engage this unwind segue.
    
    // Get the selected Category from the view controller that sent the segue - CategoryPickerViewController.
    let controller = segue.sourceViewController as CategoryPickerViewController
    categoryName = controller.selectedCategoryName
    categoryLabel.text = categoryName
  }
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //------------------------------------------
    descriptionTextView.text = descriptionText
    categoryLabel.text = categoryName

    //------------------------------------------
    latitudeLabel.text  = String(format: "%.8f", coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    
    //------------------------------------------
    // Fill in the address.
    if let placemark = placemark {
      addressLabel.text = stringFromPlacemark(placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    //------------------------------------------
    dateLabel.text = formatDate(NSDate())
    //------------------------------------------
    // Dismiss the keyboard in response to a tap anywhere on the screen.
    
    // Send message, "hideKeyboard:" when a tap is recognized anywhere in the table view.
    // The colon following the action name indicates that this method takes a single parameter, which in this case is a reference to the gesture recognizer.
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
  }
  //#####################################################################
  // MARK: - Gesture Recognition
  
  func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
    // Called whenever the user taps somewhere in the table view.
    
    // Determine where the tap occurred.
    // Method locationInView returns a CGPoint value - a struct containing x and y fields that define a position on the screen.
    let point = gestureRecognizer.locationInView(tableView)
    
    // Determine which index path is currently displayed at the position of the tap.
    let indexPath = tableView.indexPathForRowAtPoint(point)
    
    // It is possible that the user taps inside the table view but not on a cell, for example somewhere in between two sections or on the section header. 
    // In that case indexPath will be nil, making indexPath an optional (of type NSIndexPath?). 
    // An optional, such as indexPath, needs to be unwrapped either with "if let" or "!".
    // Using Short Circuiting:
    // If indexPath equals nil, then everything behind the first && is simply ignored (called Short Circuiting).
    // When the app gets to look at indexPath!.section, the value of indexPath will never be nil so forced unwrapping of indexPath (using "!") is safe.
    
    if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
      // Do NOT hide the keyboard if the user tapped in the row with the description text view.
      return
    }
    // Hide the keyboard if the user tapped anywhere other than the row with the description text view.
    descriptionTextView.resignFirstResponder()
  }
  //#####################################################################
  // MARK: - View Layout
  
  override func viewWillLayoutSubviews() {
    // Called by UIKit as part of the layout phase of the view controller when it first appears on the screen.
        
    super.viewWillLayoutSubviews()
        
    // Set the width of the text view to the width of the screen minus a 15-point margin on each side.
    descriptionTextView.frame.size.width = view.frame.size.width - 30
  }
  //#####################################################################
  // MARK: - Action Methods
  
  @IBAction func done() {
          
    // Create a HudView object and add it to the navigation controller’s view with an animation.
    let hudView = HudView.hudInView(navigationController!.view, animated: true)
          
    // Set the text property on the new object.
    hudView.text = "Tagged"
          
    // Test the descriptionText variable.
    //println("Description '\(descriptionText)'")
          
    //------------------------------------------
    //dismissViewControllerAnimated(true, completion: nil)

    // Wait a short period of time to give the Heads Up Display time to finish animating prior to closing the screen after the user clicks the Done button.
    let delayInSeconds = 0.6
/*
    // Because afterDelay() is a free function, not a method, it is not necessary to specify the "closure:" label for the second parameter.
    afterDelay(delayInSeconds, {
      // Reminder that "self" needs to be used inside a Closure.
      self.dismissViewControllerAnimated(true, completion: nil)
    })
*/
    // Rewrite in a better format...
    // Trailing Closure Syntax - a closure can be put behind a function call if the closure is the last parameter of the function.
    afterDelay(delayInSeconds) {
      self.dismissViewControllerAnimated(true, completion: nil)
    }
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
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    // Limit user taps to the first two sections of the table view.
    
    if indexPath.section == 0 || indexPath.section == 1 {
      return indexPath
    
    } else {
      return nil
    }
  }
  //#####################################################################
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // When the user taps anywhere inside the first cell, the text view should activate, even if the tap wasn’t on the text view itself.
      
    if indexPath.section == 0 && indexPath.row == 0 {
      // The user tapped somewhere in the first row - the row with the description text.
      descriptionTextView.becomeFirstResponder()
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

