//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Ed on 10/20/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  //#####################################################################

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    //------------------------------------------
    // Send the managedObjectContext to the CurrentLocationViewController.
    
    // First, find the UITabBarController.
    let tabBarController = window!.rootViewController as UITabBarController
    
    if let tabBarViewControllers = tabBarController.viewControllers {
      // The first controller in the tabBarController's array of view controllers is CurrentLocationViewController.
      let currentLocationViewController = tabBarViewControllers[0] as CurrentLocationViewController
      
      // This triggers the creation of the managed object context.
      currentLocationViewController.managedObjectContext = managedObjectContext
    }
    //------------------------------------------
    return true
  }
  //#####################################################################

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  //#####################################################################

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  //#####################################################################

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  //#####################################################################

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  //#####################################################################

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  //#####################################################################
  // MARK: - Core Data
  
  // Declare an instance variable of type NSManagedObjectContext.
  // The variable has an initial value due to this:
  //   lazy var managedObjectContext: NSManagedObjectContext = something
  // and "something" is the block of code in the Closure (i.e., between {}).
  // The () after the Closure brackets invoke the code immediately.
  
  // "lazy" means the entire block of code in the { . . . }() closure isn’t actually performed right away. 
  // The context object won’t be created until it is requested.
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    
    // Create an NSURL object that contains a URL pointing to the Core Data model that is stored in the application bundle in a folder named, "DataModel.momd".
    if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") {
    
      // Create an NSManagedObjectModel object from the Core Data model stored at modelURL.
      if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
      
        // Create an NSPersistentStoreCoordinator object to interface between the NSManagedObjectModel object and the SQLite database.
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
      
        // Create an NSURL object pointing at the DataStore.sqlite file in the app's Documents directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = urls[0] as NSURL
        let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
      
        // Create a persistent store and add the SQLite database to it.
        var error: NSError?
        if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                                              configuration: nil,
                                                              URL: storeURL,
                                                              options: nil,
                                                              error: &error) {
          // Create and return the NSManagedObjectContext.
          let context = NSManagedObjectContext()
          context.persistentStoreCoordinator = coordinator
          return context
        
        } else {
          println("Error adding persistent store at \(storeURL): \(error!)")
        }
      } else {
        println("Error initializing model from: \(modelURL)") }
    } else {
      println("Could not find data model in app bundle")
    }
    // Something went wrong.  Abort the app.
    abort()
  }()
  //#####################################################################
}

