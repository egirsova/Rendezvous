//
//  Constants.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/11/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Foundation

struct Constants {
    struct Notifications {
        static let newRendezvousPoint = "newRendezvousPointNotification"
        static let connectedUserUpdatedLocation = "connectedUserUpdatedLocation"
    }
    
    struct PubnubNotificationType {
        static let updatedLocation = "updatedLocation"
    }
    
    struct PushNotificationType {
        static let initialRequest = "initialRequestPushNotification"
        static let acceptedRequest = "acceptedRequestPushNotification"
    }
}