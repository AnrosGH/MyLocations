//
//  String+AA.swift
//  MyLocations
//
//  Created by Ed on 11/10/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import Foundation

extension String {
  
  mutating func addText(text: String?, withSeparator separator: String = "") {
    // Add text (or nil) to a regular string, with a separator such as a space or comma.
    // The separator is only used if line isn’t empty.

    // When a method changes the value of a struct (like String), it must be marked as mutating.
    // A struct is a value type and, therefore, cannot be modified when declared with let.
    // The "mutating" keyword tells Swift that the addText(withSeparator) method can only be used on strings that are made with var, but not on strings made with let.
    
    // The mutating keyword is not required on methods inside a class because classes are reference types and can always be mutated, even if they are declared with let.
    
    // Using a default parameter value (= "") for input parameter, withSeparator.  That allows the caller to omit the parameter and allow it to be set to the default.
    
    if let text = text {
      // text is NOT nil.

      if !isEmpty {
        self += separator
      }
      self += text
    }
  }
}