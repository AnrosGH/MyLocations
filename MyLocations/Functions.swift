//
//  Functions.swift
//  MyLocations
//
//  Created by Ed on 10/29/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import Foundation

// Import the Grand Central Dispatch (GCD) framework for handling asynchronous tasks.
// Used in waiting for the Head Up Display to finish animating.
import Dispatch

//#####################################################################
// MARK: - Public Global Constants

//         Only a single instance is ever created (to conserve execution time and battery power).
//         The code is run only the very first time the object is needed in the app (a.k.a. lazy loading).
//         "Global" constants can be used outside of this Swift file since they do not belong to a class.

// Assign to a global constant a parth to the app's Documents directory.
let applicationDocumentsDirectory: String = {
  let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
  return paths[0]
  
  // Using "()" after the Closure to assign the result of the closure code to applicationDocumentsDirectory.
  // Omitting "()" would assign the block of code itself to applicationDocumentsDirectory.
}()
//#####################################################################
// Free Functions that can be used anywhere in the code.

// The second parameter, closure, has type "() -> ()" which is Swift notation for a parameter that takes a closure with no arguments and no return value.
// "->" means that the type represents a closure.
// The general syntax for a closure is:
//   (parameter list) -> return type

func afterDelay(seconds: Double, closure: () -> ()) {
  
  // Convert a delay in seconds to an internal time format (measured in nanoseconds) for use with dispatch_after.
  let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
  
  // Use the delay to schedule running the code inside the closure.
  dispatch_after(when, dispatch_get_main_queue(), closure)
}