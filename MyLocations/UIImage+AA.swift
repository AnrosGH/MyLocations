//
//  UIImage+AA.swift
//  MyLocations
//
//  Created by Ed on 11/7/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit

extension UIImage {
  
  func resizedImageToFitWithBounds(bounds: CGSize) -> UIImage {
    // Resize an image to fit within the bounds of a rectangle using "Aspect Fit" rules.
  
    // ASPECT FIT RULES
    // - Maintain the aspect ratio (W/H) of the original image.
    // - Keep the entire image visible by scaling to the longest side.
    // - Allow an empty border to be visible within the bounds if needed in order to fit the entire image within the bounds.
  
    // Calculate how big the image can be in order to fit inside the bounded rectangle using the “aspect fit” approach to keep the aspect ratio intact.
    let horizontalRatio = bounds.width / size.width
    let verticalRatio = bounds.height / size.height
  
    // Use the smaller of the two ratios to ensure that the entire image fits within the bounds.
    let ratio = min(horizontalRatio, verticalRatio)
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
  
    // Create a new image context and draw the image into it.
    UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
    drawInRect(CGRect(origin: CGPoint.zeroPoint, size: newSize))
  
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  
    return newImage
  }
  //#####################################################################
  
  func resizedImageToFillWithBounds(bounds: CGSize) -> UIImage {
      // Resize an image to fit within the bounds of a rectangle using "Aspect Fill" rules.
      
      // ASPECT FILL RULES
      // - Maintain the aspect ratio (W/H) of the original image.
      // - Keep the entire image height visible by scaling to the bounded height.
      // - Allow the sides of the image to spill out over the bounded width if necessary.
      
      // OrigImageWidth    NewImageWidth
      // --------------  = --------------
      // OrigImageHeight   NewImageHeight
      
      //                   OrigImageWidth
      // NewImageWidth   = --------------  * NewImageHeight
      //                   OrigImageHeight
      
      //                   size.width
      // NewImageWidth   = -----------  * bounds.height
      //                   size.height
      
      // NewImageWidth   = aspectRatio  * bounds.height
      
      // Calculate the aspect ratio of the original image.
      let aspectRatio = size.width / size.height
      
      let newImageWidth = aspectRatio * bounds.height
      
      let newSize = CGSize(width: newImageWidth, height: bounds.height)
      
      // Create a new image context and draw the image into bounded rectangle (as opposed to the new image size).
      UIGraphicsBeginImageContextWithOptions(bounds, true, 0)
      
      // If the sides are able to spill out over the bounded width, then the x-coordinate of the new image must be set such that 
      // the extra image area spills out evenly on both sides of the width of the bounded rectangle. 
      // The x-coordinate of the new image will actually be to the left (i.e. negative) of the bounded rectangle 
      // if the new image width is greater than the width of the bounded rectangle.
      let xCoord = -(newImageWidth - bounds.width) / 2
      
      drawInRect(CGRect(origin: CGPoint(x:xCoord, y:0), size: newSize))
      
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage
  }
  //#####################################################################
}