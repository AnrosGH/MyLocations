//
//  LocationCell.swift
//  MyLocations
//
//  Created by Ed on 10/30/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  @IBOutlet weak var photoImageView: UIImageView!
  
  //#####################################################################
  // MARK: - Cell Setup
  
  func configureForLocation(location: Location) {
    
    //------------------------------------------
    // DESCRIPTION

    if location.locationDescription.isEmpty {
      descriptionLabel.text = "(No Description)"
      
    } else {
      descriptionLabel.text = location.locationDescription
    }
    //------------------------------------------
    // ADDRESS
    
    if let placemark = location.placemark {
      // addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare)," + "\(placemark.locality)"
      
      // Take advantage of the custom String extension method, addText, in String+AA.swift.
      var text = ""
      
      text.addText(placemark.subThoroughfare)
      text.addText(placemark.thoroughfare, withSeparator: " ")
      text.addText(placemark.locality, withSeparator: ", ")
      
      addressLabel.text = text
      
    } else {
      // Display latitude and longitude if the Location has not been tagged.
      addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
    }
    //------------------------------------------
    // IMAGE THUMBNAIL
    
    photoImageView.image = imageForLocation(location)
  }
  //#####################################################################
  
  override func awakeFromNib() {
    // Every object that comes from a storyboard has the awakeFromNib() method. 
    // This method is invoked when UIKit loads the object from the storyboard. It’s the ideal place to customize its looks.
    
    super.awakeFromNib()
    
    // Change the appearance of the table view cells.
    backgroundColor = UIColor.blackColor()
    descriptionLabel.textColor = UIColor.whiteColor()
    descriptionLabel.highlightedTextColor = descriptionLabel.textColor
    addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
    addressLabel.highlightedTextColor = addressLabel.textColor
    
    //------------------------------------------
    // Without this code, tapping a cell would cause it to light up in a bright color.
    // Since there is no “selectionColor” property on UITableViewCell, the alternative is to give the cell a different view to display when it is selected.
    
    // Create a new UIView filled with a dark gray color.
    let selectionView = UIView(frame: CGRect.zeroRect)
    selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    
    // Place the new view on top of the cell’s background when the user taps on the cell. 
    selectedBackgroundView = selectionView
    
    //------------------------------------------
    // Make thumbnail images rounded.
    // This gives the image view rounded corners with a radius that is equal to half the width of the image, which makes it a perfect circle.
    photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
    
    // Make sure that the image view respects these rounded corners and does not draw outside them.
    photoImageView.clipsToBounds = true
    
    // Move the separator lines between the cells a bit to the right so there are no lines between the thumbnail images.
    separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
  }
  //#####################################################################
  // MARK: - Photo Thumbnail
  
  func imageForLocation(location: Location) -> UIImage {
    
    if location.hasPhoto {
      if let image = location.photoImage {
        return image.resizedImageToFitWithBounds(CGSize(width: 52, height: 52))
      }
    }
    // No image exists.  Return a placeholder image.
    // (UIImage(named) is a failable initializer, so it returns an optional.)
    return UIImage(named: "No Photo")!
  }
  //#####################################################################
}
