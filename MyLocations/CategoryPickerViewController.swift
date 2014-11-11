//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Ed on 10/28/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
  
  // Used for showing a checkmark next to the currently selected category.
  var selectedCategoryName = ""
  
  // Set up an array of categories.
  let categories = [
    "No Category",
    "Apple Store",
    "Bar",
    "Bookstore",
    "Club",
    "Grocery Store",
    "Historic Building",
    "House",
    "Icecream Vendor",
    "Landmark",
    "Park"]
  
  // When the user taps a row, the checkmark denoting the currently selected category needs to be removed from the previously selected cell
  // and added to the newly selected cell.
  var selectedIndexPath = NSIndexPath()
  
  //#####################################################################
  // MARK: - Unwind Segues
  
  // Invoked when the unwind segue is triggered.
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "PickedCategory" {
      // Send the selected category back to the LocationDetailViewController by updating this view controller's property, selectedCategoryName.
      
      let cell = sender as UITableViewCell
      
      if let indexPath = tableView.indexPathForCell(cell) {
        selectedCategoryName = categories[indexPath.row]
      }
    }
  }
  //#####################################################################
  // MARK: - UIViewController - Managing the View
  
  // viewDidLoad() is called after prepareForSegue().
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    //------------------------------------------
    // Make the table view black (although this does not alter the cells themselves).
    
    tableView.backgroundColor = UIColor.blackColor()
    tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
    tableView.indicatorStyle = .White
  }
  //#####################################################################
}
//#####################################################################
// MARK: - Table View Data Source

extension CategoryPickerViewController: UITableViewDataSource {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }
  //#####################################################################
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    // Use prototype cells designed in Interface BuilderCreate instead of creating the table view cell in code.
    
    // Get a copy of the prototype cell – either a new one or a recycled one.
    // Type Cast Note:
    //   dequeueReusableCellWithIdentifier() can return nil if there is no cell object to reuse.
    //   When using prototpye cells, however, dequeueReusableCellWithIdentifier() will never return nil so
    //   so a non-optional constant can be type cast using "as UITableViewCell" (as opposed to "as? UITableViewCell" for an optional).
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
    
    // Get the category name that corresponds to this row.
    let categoryName = categories[indexPath.row]
    cell.textLabel.text = categoryName

    //------------------------------------------
    if categoryName == selectedCategoryName {
      // This row IS the currently selected category.
      
      cell.accessoryType = .Checkmark
      selectedIndexPath = indexPath
      
    //------------------------------------------
    } else {
      // This row is NOT the currently selected category.
      cell.accessoryType = .None
    }
    //------------------------------------------
    return cell
  }
  //#####################################################################
}
//#####################################################################
// MARK: - Table View Delegate

extension CategoryPickerViewController: UITableViewDelegate {
  
  //#####################################################################
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  
    if indexPath.row != selectedIndexPath.row {
      // The user selected a category that is different from the one previously selected.
      
      if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
        // Turn ON the checkmark next to the newly selected category.
        newCell.accessoryType = .Checkmark
      }
      
      if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
        // Turn OFF the checkmark next to the previously selected category.
        oldCell.accessoryType = .None
      }
      // Update the variable that tracks the currently selected category.
      selectedIndexPath = indexPath
    }
  }
  //#####################################################################
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // This method is called just before a cell becomes visible.
    
    // Set the background and text colors of the cells.
    
    cell.backgroundColor = UIColor.blackColor()
    cell.textLabel.textColor = UIColor.whiteColor()
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor
    
    let selectionView = UIView(frame: CGRect.zeroRect)
    selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    cell.selectedBackgroundView = selectionView
  }
  //#####################################################################
}