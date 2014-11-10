//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Ed on 11/10/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
  
  // It will look better if the status bar text is white instead.
  // To control the color of the status bar text, method, preferredStatusBarStyle(), in the view controllers needs to be overridden to return the value .LightContent.
  // For some reason that won’t work for view controllers embedded in a Navigation Controller, such as the Locations tab and the Tag/Edit Location screens.
  // The simplest way to make the status bar white for all view controllers in the entire app is to replace the UITabBarController with a subclass like this one.
  
  override func childViewControllerForStatusBarStyle() -> UIViewController? {
    // Returning "nil" causes the Tab Bar Controller to look at its own preferredStatusBarStyle() method.
    // In the storyboard, the Tab Bar Controller is set to this Class, so "its own preferredStatusBarStyle() method" is the one that follows below.
    return nil
  }
  //#####################################################################
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    
    return .LightContent
  }
  //#####################################################################
}