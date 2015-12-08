//
//  Contact.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/5/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

class Contact: NSObject {
    var fullname: String!
    var rPhone: String!
    var rUsername: String!

    init(fullname: String, phone: String, username: String) {
     super.init()
        self.fullname = fullname
        self.rPhone = phone
        self.rUsername = username
    }
    
}
