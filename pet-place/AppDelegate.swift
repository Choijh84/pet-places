//
//  AppDelegate.swift
//  pet-place
//
//  Created by Owner on 2016. 12. 31..
//  Copyright © 2016년 press.S. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let APP_ID = "6E11C098-5961-1872-FF85-2B0BD0AA0600"
    let SECRET_KEY = "582E29FF-AB79-01D4-FFB7-B22F163C0B00"
    let VERSION_NUM = "v1"

    var backendless = Backendless.sharedInstance()
    
    /**
     Load our customization here when the app starts, set up the Parse ID and set the global tintColor
     
     :param: application   applicadtion	The singleton app object.
     :param: launchOptions A dictionary indicating the reason the app was launched (if any).
     
     :returns: NO if the app cannot handle the URL resource or continue a user activity, otherwise return YES.
     */

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        CustomizeAppearance.globalCustomization()
        window?.tintColor = UIColor.globalTintColor()
        
        backendless?.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        GMSPlacesClient.provideAPIKey("AIzaSyBwzZ6Mx2_3cn0mCFS4I2guim4T2Mu1IFs")
        GMSServices.provideAPIKey("AIzaSyBwzZ6Mx2_3cn0mCFS4I2guim4T2Mu1IFs")
        IQKeyboardManager.sharedManager().enable = true
        
        if GeneralSettings.isOnboardingFinished() == false {
            window?.rootViewController = StoryboardManager.onboardingViewController()
        } else {
            window?.rootViewController = StoryboardManager.homeTabbarController()
        }
        
        return true
    }
    
    /**
     Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options.
     
     - parameter application:       Your singleton app object.
     - parameter url:               The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
     - parameter options:           A dictionary of launch options
     
     - returns: the application
     */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print("AppDelegate -> application:openURL: \(String(describing: url.scheme))")
        
        let backendless = Backendless.sharedInstance()
        let user = backendless?.userService.handleOpen(url)
        if user != nil {
            print("AppDelegate -> application:openURL: user = \(String(describing: user))")
            
            // do something, call some ViewController method, for example
        }
        
        return true
        // return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    /**
     Tells the delegate that the app has become active.
     
     - parameter application: Your singleton app object.
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "pet_place")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

