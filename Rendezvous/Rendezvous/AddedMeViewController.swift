//
//  AddedMeViewController.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/7/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

class AddedMeViewController: UIViewController {
    
    @IBOutlet var requestsTable: UITableView!
    var requests = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestsTable.dataSource = self
        requestsTable.delegate = self
    }
    
    override func awakeFromNib() {
        // Update the table to include all new pending requests
        let query = PFQuery(className: "FriendRequest")
        query.whereKey("to", equalTo: PFUser.currentUser()!)
        query.whereKey("status", equalTo: RequestStatus.pending)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    print("object: \(object)")
                    let user = object.objectForKey("from") as! PFUser
                    self.requests.append(user)
                    self.requestsTable.reloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension AddedMeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath)
        
        let query = PFUser.query()
        let user = self.requests[indexPath.item]
        query?.whereKey("objectId", equalTo: user.objectId!)
        
        query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    let username = object.objectForKey("username") as! String
                    user.username = username
                    cell.textLabel?.text = username
                }
            }
        }
        
        
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.requestsTable.cellForRowAtIndexPath(indexPath)
        // Add user with that cell
        let username = cell?.textLabel!.text
        
        // First get user associated with the username
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", equalTo: username!)
        
        userQuery?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    let user = object as! PFUser
                    
                    let query = PFQuery(className: "FriendRequest")
                    query.whereKey("from", equalTo: user)
                    
                    query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                        if error == nil {
                            for object in objects! {
                                object.setObject(RequestStatus.accepted, forKey: "status")
                                object.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                                    if succeeded {
                                        // Alert user that request was sent successfully
                                        print("updated status successfully")
                                    } else {
                                        // Alert user that there was an error
                                        print("updated status unsuccessfully")
                                    }
                                }
                                
                                // Now create a relation for current user
                                let relation = PFUser.currentUser()?.relationForKey("Friendship")
                                relation?.addObject(user)
                                PFUser.currentUser()?.saveInBackground()
                                
                                // Now create relation for requesting user
                                let relation2 = user.relationForKey("Friendship")
                                relation2.addObject(PFUser.currentUser()!)
                                user.saveInBackground()
                                
                            }
                        }
                    }
                    
                }
            }
        }
        
    }
}
