//
//  RendezvousViewController.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/4/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit
import Contacts

class RendezvousViewController: UIViewController {
    
    @IBOutlet var friendsTable: UITableView!
    var friends: [PFUser]!
    var selectedCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTable.dataSource = self
        friendsTable.delegate = self
        
        friends = [PFUser]()
        
        // load all friends
        let friendsRelation = PFUser.currentUser()?.relationForKey("Friendship")
        friendsRelation?.query().findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        self.friends.append(object as! PFUser)
                        self.friendsTable.reloadData()
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rendezvousButtonPressed(sender: UIButton) {
        let username = selectedCell?.textLabel!.text
        
        // First get user associated with username
        var friend = PFUser()
        for user in friends {
            if user.username == username {
                friend = user
            }
        }
        
        let message = "\(PFUser.currentUser()!.username!) wants to Rendezvous"
        let geoLocation = PFGeoPoint(location: CurrentUser.user.location)
        PFCloud.callFunctionInBackground("sendPushToUser", withParameters: ["recipientId": friend.objectId!, "message": message, "location": geoLocation, "pushNotificationType": Constants.PushNotificationType.initialRequest], block: {
            (object, error) -> Void in
            
            if error == nil {
                // show confirmation
                let alert = UIAlertController(title: "Request Sent!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: true, completion: nil)
                NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "hideAlert", userInfo: nil, repeats: false)
            }
        })
        
    }
    
    func hideAlert() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func convertNumberIntoDigitsOnly(phoneNumber: String) -> String {
        return phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

extension RendezvousViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int
        
        if let friendsArray = self.friends {
            count = friendsArray.count
        } else {
            count = 0
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.friends[indexPath.item].username
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.friendsTable.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.None {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell?.selectionStyle = UITableViewCellSelectionStyle.Blue
            cell?.selected = true
            selectedCell = cell
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell?.selected = false
            selectedCell = nil
        }
    }
}
