//
//  MyNavigationController.swift
//  MyLocations
//
//  Created by Ed on 11/10/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {
  
  // UITabBarController was subclassed with MyTabBarController to make the status bar text white.
  // The Navigation Controller that embeds the Tag/Edit Location screen needs to be subclassed because it is presented modally on top of the other screens 
  // and is therefore not part of the Tab Bar Controller hierarchy.
  
  // To control the color of the status bar text, method, preferredStatusBarStyle(), in the view controllers needs to be overridden to return the value .LightContent.
  // For some reason that won’t work for view controllers embedded in a Navigation Controller, such as the Locations tab and the Tag/Edit Location screens.

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
  
  return .LightContent
  }
}