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
        // Do any additional setup after loading the view.
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
