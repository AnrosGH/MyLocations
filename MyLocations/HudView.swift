//
//  HudView.swift
//  MyLocations
//
//  Created by Ed on 10/28/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit

class HudView: UIView {  // Heads Up Display (HUD)

  var text = ""
  
  //#####################################################################
  // MARK: - Convenience Constructors 
  
  // Convenience Constructors are always class methods.  
  // Class methods work on the class as a whole and not on any particular instance.
  // For coding convenience, Convenience Constructors not only create an instance of an object but do other initialization work as well.
  
  class func hudInView(view: UIView, animated: Bool) -> HudView {
    // Create and return a new HudView instance.
    
    // Create the instance by calling HudView(frame) which is an init method inherited from UIView.
    let hudView = HudView(frame: view.bounds)
    hudView.opaque = false
    
    // Add the new HudView object as a subview on top of the view object passed to this method.  
    // (If the view passed to this method is a navigation controller's view, the HUD will cover the entire screen.)
    view.addSubview(hudView)
    
    // Disable any further user interaction with the screen.
    view.userInteractionEnabled = false
    
    // TESTING ONLY: Set the HUD view's background color to 50% transparent red to demonstrate that the HUD covers the entire screen.
    //hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    
    return hudView
  }
  //#####################################################################
  // MARK: - UIKit Overrides
  
  override func drawRect(rect: CGRect) {
    // This method is invoked whenever UIKit wants a view from the app to redraw itself.
    // Everything in iOS is event-driven. Nothing gets drawn on the screen unless UIKit sends the drawRect() event. 
    // That means drawRect() should never be called from the app's code.
      
    // Redrawing of a view can be initiated by the app by sending UIKit the setNeedsDisplay() message.  UIKit will then trigger a drawRect() event when it is ready.
      
    //------------------------------------------
    // Draw a filled rectangle with rounded corners in the center of the screen.
      
    // Set the dimensions of the rectangle to 96 x 96 points.
    // (UIKit represents decimal numbers using type CGFloat.)
    let boxWidth:  CGFloat = 96
    let boxHeight: CGFloat = 96
      
    // Center the HUD rectangle on the screen.
    // bounds.size = screen size
    // Using function "round" to make sure the rectangle doesn’t end up on fractional pixel boundaries because that makes the image look fuzzy.
    let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2),
                         y: round((bounds.size.height - boxHeight) / 2),
                         width: boxWidth,
                         height: boxHeight)

    // Use a UIBezierPath object to draw rectangle object, boxRect, with rounded corners.
    let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
      
    // Fill with an 80% opaque dark gray color.
    UIColor(white: 0.3, alpha: 0.8).setFill()
      
    roundedRect.fill()
      
    //------------------------------------------
    // Add a checkmark to the Heads Up Display (HUD)
      
    // It is possible that loading the image fails, because there is no image with the specified name or the file doesn’t really contain a valid image.
    // Therefore, UIImage(named) is a failable initiaizer.  The method is really defined as, "init?(named)", and returns an optional.
    // As a result, UIImage(named) must be unwrapped with an "if let" before it can be used.
      
    // Load the checkmark image from Images.xcassets into a UIImage object.
    if let image = UIImage(named: "Checkmark") {
      
      // Calculate the position for the checkmark image based on the center coordinate of the HUD view (center) and the dimensions of the image (image.size).
      let imagePoint = CGPoint(x: center.x - round(image.size.width / 2),
                               y: center.y - round(image.size.height / 2) - boxHeight / 8)
      
      // Draw the image at the center coordinate.
      image.drawAtPoint(imagePoint)
    }
    //------------------------------------------
    // Text drawing
      
    // Create a UIFont object for the text with System font (in iOS 8, Helvetica Neue) of size 16 with plain, white text.
    // Store the font and foreground color in dictionary attribs.
    let attribs = [ NSFontAttributeName: UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName: UIColor.whiteColor() ]
      
    // Calculate the height and width of the text.
    // sizeWithAttributes(attributes) returns an object of type CGSize.
    let textSize = text.sizeWithAttributes(attribs)
      
    // Calculate where to draw the text.
    let textPoint = CGPoint(x: center.x - round(textSize.width / 2),
                            y: center.y - round(textSize.height / 2) + boxHeight / 4)
      
    // Draw the text.
    text.drawAtPoint(textPoint, withAttributes: attribs)
  }
  //#####################################################################
}