//
//  SettingsViewController.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/7/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

struct RequestStatus {
    static var pending = "pending"
    static var accepted = "accepted"
    static var declined = "declined"
}

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addFriendButtonPressed(sender: UIButton) {
        let alert = UIAlertController(title: "Add Friend", message: "Enter username of friend:", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.textFields![0].placeholder = "Username..."
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let sendRequestAction = UIAlertAction(title: "Send Request", style: UIAlertActionStyle.Default, handler: { action -> Void in
            
            let username = alert.textFields![0].text
            let query = PFUser.query()
            query?.whereKey("username", equalTo: username!)
            
            query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    if objects!.count > 0  {
                        // Send request to user
                        let user = objects!.first
                        let friendRequest = PFObject(className: "FriendRequest")
                        friendRequest.setObject(PFUser.currentUser()!, forKey: "from")
                        friendRequest.setObject(user!, forKey: "to")
                        friendRequest.setObject(RequestStatus.pending, forKey: "status")
                        friendRequest.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                            if succeeded {
                                // Alert user that request was sent successfully
                                self.tempAlert("Friend Request Sent", message: nil)
                            } else {
                                // Alert user that there was an error
                                self.tempAlert("Unsuccessful", message: "Error: \(error)")
                            }
                        }
                    } else {
                        // Let user know that no such user exists
                        self.tempAlert("Invalid User", message: "The username that you specified does not exist :(")
                    }
                } else {
                    print("Error retrieving data: \(error) \(error!.userInfo)")
                }
            }
        })
        alert.addAction(cancelAction)
        alert.addAction(sendRequestAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tempAlert(title: String, message: String?) {
        let alert: UIAlertController
        if message != nil {
            alert = UIAlertController(title: title, message: message!, preferredStyle: UIAlertControllerStyle.Alert)
        } else {
            alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        }

        self.presentViewController(alert, animated: true, completion: nil)
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "hideAlert", userInfo: nil, repeats: false)
    }
    
    func hideAlert() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
