//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Ed on 10/27/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UITableViewController {
  
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  //#####################################################################
  // MARK: - Initialization
  
  //#####################################################################
  // MARK: - Action Methods
  
  @IBAction func done() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  //#####################################################################
  @IBAction func cancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  //#####################################################################
}