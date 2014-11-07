//
//  UIImage+AA.swift
//  MyLocations
//
//  Created by Ed on 11/7/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit

extension UIImage {
  
  func resizedImageWithBounds(bounds: CGSize) -> UIImage {
    // Resize an image to fit within the bounds of a rectangle.
  
    // Calculate how big the image can be in order to fit inside the bounds rectangle using the “aspect fit” approach to keep the aspect ratio intact.
    let horizontalRatio = bounds.width / size.width
    let verticalRatio = bounds.height / size.height
    let ratio = min(horizontalRatio, verticalRatio)
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
  
    // Create a new image context and draw the image into it.
    UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
    drawInRect(CGRect(origin: CGPoint.zeroPoint, size: newSize))
  
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  
    return newImage
  }
}