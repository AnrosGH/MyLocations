//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Ed on 10/20/14.
//  Copyright (c) 2014 Anros Applications, LLC. All rights reserved.
//

import UIKit
import CoreData

//#####################################################################
// Free Functions that can be used anywhere in the code.

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: NSError?) {
  // It is unlikely, but possible, that this function is called without a proper NSError object, which is why the error parameter has type "NSError?".
  
  if let error = error {
    // "error" is not nil, so output the Core Data error message to the Debug Area.
    println("*** Fatal error: \(error), \(error.userInfo)")
  }
  // Create a custom notification.
  NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}
//#####################################################################

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
      
      //--------------------
      // Look up the LocationsViewController in the storyboard and give it a reference to the managed object context.
      let navigationController = tabBarViewControllers[1] as UINavigationController
      let locationsViewController = navigationController.viewControllers[0] as LocationsViewController
      locationsViewController.managedObjectContext = managedObjectContext
      
      // Do the same for the MapViewController.
      let mapViewController = tabBarViewControllers[2] as MapViewController
      mapViewController.managedObjectContext = managedObjectContext
      //--------------------
      // FIX FOR iOS 7 & 8 BUG.
      // THIS FIX DID NOT WORK!
      // Force the LocationsViewController to load its view immediately when the app starts up. 
      // Without this, it delays loading the view until the user switches tabs, causing Core Data to get confused.
      //let forceTheViewToLoad = locationsViewController.view
    }
    //------------------------------------------
    // Error handling for a possible Core Data fatal error.
    listenForFatalCoreDataNotifications()
    
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
          
          // Print the location of the SQLite database.
          println(storeURL)
          
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
  // MARK: - Core Data Fatal Error Handling
    
  func listenForFatalCoreDataNotifications() {
            
    // Register with the NSNotificationCenter for custom notification, MyManagedObjectContextSaveDidFailNotification.
    NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification,
                                                            object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            
      // The code here in Closure "usingBlock", gets executed when the NSNotificationCenter adds an observer for notification, MyManagedObjectContextSaveDidFailNotification.
      // Closure usingBlock has one input parameter, notification, an NSNotification object.
      // Since input parameter, notification, is not used in the Closure, a wildcard could also be used:
      //     "{ _ in" instead of "{ notification in"
      // to indicate to Swift that the parameter is being ignored.
            
      // Create a UIAlertController to contain the error message.
      let alert = UIAlertController(title: "Internal Error",
                                  message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.",
                           preferredStyle: .Alert)
            
      // Create and return (initialize) an alert action with a specified title and behavior for the alert's OK button.
      // (The use of the wildcard "_" indicates that the input parameter, UIAlertAction, is being ignored.  Refer to documentation for UIAlertAction.)
      let action = UIAlertAction(title: "OK", style: .Default) { _ in
        
        // Create an NSException object to provide information to the crash log.
        let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
        exception.raise()
      }
      // Add the action object to the UIAlertController object.
      alert.addAction(action)
            
      // Present the alert to the view controller that is currently visible.
      self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
    })
  }
  //#####################################################################
  // 5
  func viewControllerForShowingAlert() -> UIViewController {
    // Find the view controller that is currently visible.
              
    let rootViewController = self.window!.rootViewController!
              
    if let presentedViewController = rootViewController.presentedViewController {
      return presentedViewController
    } else {
      return rootViewController
    }
  }
  //#####################################################################
}

