//
//  AppDelegate.swift
//  shareMap
//
//  Created by Likai Yan on 4/7/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import UIKit
import Firebase
import TwitterKit
import Fabric
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    
//    struct currLoc{
//        var long: Double = 0;
//        var latitude: Double = 0;
//    }
//    
//    var currentLocation:currLoc;
//    // http://stackoverflow.com/questions/42192961/add-firapp-configure-to-your-application-initialization-error
//    override init() {
//        var duh = currLoc();
//        duh.latitude = 0
//        duh.long = 0;
//        currentLocation = duh;
//        
//        super.init()
//
//        // self.currentLocation.long = 0;
//        // self.currentLocation.latitude = 0;
//        FIRApp.configure()
//        // not really needed unless you really need it        FIRDatabase.database().persistenceEnabled = true
//    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Twitter.self])
        return true
        
    }
    
    func application(_ application:UIApplication,open url:URL,sourceApplication:String?,annotation:Any)->Bool{
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
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

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

