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
