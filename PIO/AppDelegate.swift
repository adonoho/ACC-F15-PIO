//
//  AppDelegate.swift
//  PIO
//
//  Created by Andrew Donoho on 10/16/15.
//  Copyright © 2015 Donoho Design Group, LLC. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func configureRootViewController() {

        if let svc = window?.rootViewController as? UISplitViewController {

            svc.delegate = self

            let controllers = svc.viewControllers

            if let master = controllers.first as? UINavigationController,
                mvc = master.topViewController as? MasterViewController {

                    mvc.managedObjectContext = managedObjectContext

                    if let detail = controllers.last as? UINavigationController,
                        navItem = detail.topViewController?.navigationItem
                        where detail != master {

                            navItem.leftItemsSupplementBackButton = true
                            navItem.leftBarButtonItem = svc.displayModeButtonItem()
                    }
            }
        }
        
    } // configureRootViewController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        configureRootViewController()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let dnc = secondaryViewController as? UINavigationController,
            dvc = dnc.topViewController as? DetailViewController else { return false }

        if dvc.item == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ddg.PIO" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last!
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("PIO", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")

        let options: [NSObject: AnyObject] = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        do { try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil,
            URL: url,
            options: options)
        }
        catch let addError as NSError {

            // Report any error we got.
            let userInfo = [
                NSLocalizedDescriptionKey: "Failed to initialize the application's saved data",
                NSLocalizedFailureReasonErrorKey: "There was an error creating or loading the application's saved data.",
                NSUnderlyingErrorKey: addError
            ]
            let error = NSError(domain: "com.ddg.error", code: 9999, userInfo: userInfo)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    func didSaveNotification(notification: NSNotification) {

        managedObjectContext.performBlock {

            self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)

        moc.persistentStoreCoordinator = self.persistentStoreCoordinator

        let nc = NSNotificationCenter.defaultCenter()

        nc.addObserver(self, selector: "didSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil)

        return moc
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do { try managedObjectContext.save() }
            catch let error as NSError {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

}

