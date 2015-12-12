//
//  AppDelegate.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/3/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit
import PubNub

class CurrentUser {
    struct user {
        static var pfUser = PFUser.currentUser()
        static var location: CLLocation = CLLocation()
        static var pnClient: PubNub!
        static var connectedUser: String?
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var client: PubNub?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Connect to Parse
        Parse.setApplicationId(ApiKeys.parseApplicationId, clientKey: ApiKeys.parseClientKey)
        
        // Connect to PubNub
        let configuration = PNConfiguration(publishKey: ApiKeys.pubnubPublishKey, subscribeKey: ApiKeys.pubnubSubscribeKey)
        client = PubNub.clientWithConfiguration(configuration)
        client?.addListener(self)
        CurrentUser.user.pnClient = client
        
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
            CurrentUser.user.pnClient.subscribeToChannels([PFUser.currentUser()!.objectId!], withPresence: true)
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
        
        // Push Notification Type: Initial Request
        if pushNotificationType == Constants.PushNotificationType.initialRequest {
            
            let alert = UIAlertController(title: "Rendezvous Request", message: receivedMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.Cancel, handler: nil)
            let acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: { action -> Void in
                CurrentUser.user.connectedUser = senderId
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
            
        }   // Push Notification Type: Accepted Request
        else if pushNotificationType == Constants.PushNotificationType.acceptedRequest {
            let alert = UIAlertController(title: "Accepted", message: receivedMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let acceptAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: { action -> Void in
                CurrentUser.user.connectedUser = senderId
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

extension AppDelegate: PNObjectEventListener {
    // Handle new message from one of channels on which client has been subscribed.
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        
        // Handle new message stored in message.data.message
        if message.data.actualChannel != nil {
            
            // Message has been received on channel group stored in
            // message.data.subscribedChannel
        }
        else {
            
            // Message has been received on channel stored in
            // message.data.subscribedChannel
        }
        
        print("Received notification: \(message.data.message)")
        if let notificationType = message.data.message["type"] {
            let typeString = notificationType as! String
            if typeString == Constants.PubnubNotificationType.updatedLocation {
                let latitudeNumber = message.data.message["latitude"] as! NSNumber
                let longitudeNumber = message.data.message["longitude"] as! NSNumber
                let latitude = CLLocationDegrees(Double(latitudeNumber))
                let longitude = CLLocationDegrees(Double(longitudeNumber))
                let newLocation = CLLocation(latitude: latitude, longitude: longitude)
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.connectedUserUpdatedLocation, object: self, userInfo: ["location": newLocation])
            }
        }
    }
    
    // New presence event handling.
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
        // state-change).
        if event.data.actualChannel != nil {
            
            // Presence event has been received on channel group stored in
            // event.data.subscribedChannel
        }
        else {
            
            // Presence event has been received on channel stored in
            // event.data.subscribedChannel
        }
        
        if event.data.presenceEvent != "state-change" {
            
            print("\(event.data.presence.uuid) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            print("\(event.data.presence.uuid) changed state at: " +
                "\(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) to:\n" +
                "\(event.data.presence.state)");
        }
    }
    
    
    // Handle subscription status change.
    func client(client: PubNub!, didReceiveStatus status: PNStatus!) {
        
        if status.category == .PNUnexpectedDisconnectCategory {
            
            // This event happens when radio / connectivity is lost
        }
        else if status.category == .PNConnectedCategory {
            
            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for
            // UI / internal notifications, etc
            
            // Select last object from list of channels and send message to it.
//            let targetChannel = client.channels().last as! String
//            client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
//                compressed: false, withCompletion: { (status) -> Void in
//                    
//                    if !status.error {
//                        
//                        // Message successfully published to specified channel.
//                    }
//                    else{
//                        
//                        // Handle message publish error. Check 'category' property
//                        // to find out possible reason because of which request did fail.
//                        // Review 'errorData' property (which has PNErrorData data type) of status
//                        // object to get additional information about issue.
//                        //
//                        // Request can be resent using: status.retry()
//                    }
//            })
        }
        else if status.category == .PNReconnectedCategory {
            
            // Happens as part of our regular operation. This event happens when
            // radio / connectivity is lost, then regained.
        }
        else if status.category == .PNDecryptionErrorCategory {
            
            // Handle messsage decryption error. Probably client configured to
            // encrypt messages and on live data feed it received plain text.
        }
    }
}

