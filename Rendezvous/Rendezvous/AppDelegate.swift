//
//  AppDelegate.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/3/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Connect to Parse
        Parse.setApplicationId(ApiKeys.parseApplicationId, clientKey: ApiKeys.parseClientKey)
        
        // Connect to GoogleMaps
        GMSServices.provideAPIKey(ApiKeys.googleMapsKey)
        
        // Register for push notifications
        let userNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(userNotificationSettings)
        application.registerForRemoteNotifications()
        
        // Check if logged in or not
        let currentUser = PFUser.currentUser()
        var storyboardID: String
        if currentUser != nil {
            // Show main screen
            storyboardID = "mainView"
        } else {
            // Show login screen
            storyboardID = "loginView"
        }
        
        let rootViewController = self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier(storyboardID)
        self.window?.rootViewController = rootViewController
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation["user"] = PFUser.currentUser()
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //PFPush.handlePush(userInfo)
        
        print("userinfo: \(userInfo)")
        let pushNotificationType = userInfo["pushNotificationType"] as! String
        let receivedMessage = userInfo["aps"]!["alert"]! as! String
        let senderId = userInfo["senderId"]! as! String
        let latitude = userInfo["location"]!["latitude"]! as! NSNumber
        let longitude = userInfo["location"]!["longitude"]! as! NSNumber
        
        let sentLocation = CLLocation(latitude: Double(latitude) , longitude: Double(longitude))
        
        if pushNotificationType == Constants.PushNotificationType.initialRequest {
            
            let alert = UIAlertController(title: "Rendezvous Request", message: receivedMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.Cancel, handler: nil)
            let acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: { action -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.newRendezvousPoint, object: self, userInfo: ["location": sentLocation])
                // Now send own location to the other user
                let message = "\(PFUser.currentUser()!.username!) accepted your Rendezvous request"
                let geoLocation = PFGeoPoint(location: CurrentUser.user.location)
                PFCloud.callFunctionInBackground("sendPushToUser", withParameters: ["recipientId": senderId, "message": message, "location": geoLocation, "pushNotificationType": Constants.PushNotificationType.acceptedRequest], block: {
                    (object, error) -> Void in
                    
                    if error != nil {
                        print("Error sending own location")
                    }
                })
            })
            alert.addAction(declineAction)
            alert.addAction(acceptAction)
            self.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
            
        } else if pushNotificationType == Constants.PushNotificationType.acceptedRequest {
            let alert = UIAlertController(title: "Accepted", message: receivedMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let acceptAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: { action -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.newRendezvousPoint, object: self, userInfo: ["location": sentLocation])
            })
            alert.addAction(acceptAction)
            self.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        }
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
    }
    
    
}

