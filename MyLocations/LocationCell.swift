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
  
  //#####################################################################
  
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
      addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare)," + "\(placemark.locality)"
        
    } else {
      // Display latitude and longitude if the Location has not been tagged.
      addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
    }
  }
  //#####################################################################
}
