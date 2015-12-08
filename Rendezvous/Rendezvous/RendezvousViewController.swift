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
    
    @IBOutlet var contactsTable: UITableView!
    var contactsWithApp: [Contact]!
    var selectedCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsTable.dataSource = self
        contactsTable.delegate = self
        
        contactsWithApp = [Contact]()
        
        // Find all of the contacts that use the same app
        let store = CNContactStore()
        do {
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
            try store.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: keysToFetch)) {
                (contact, cursor) -> Void in
                if !contact.phoneNumbers.isEmpty {
                    for number in contact.phoneNumbers {
                        let cnNumber = number.value as! CNPhoneNumber
                        let numberString = cnNumber.stringValue
                        let digitsOnly = numberString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                        let query = PFUser.query()
                        query?.whereKey("phone", equalTo: digitsOnly)
                        
                        query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                            if error == nil {
                                if objects!.count > 0  {
                                    print("found objects: \(objects!.first)")
                                    let fullname = contact.givenName+" "+contact.familyName
                                    let username = objects!.first!.valueForKey("username") as! String
                                    let newContact = Contact(fullname: fullname, phone: digitsOnly, username: username)
                                    self.contactsWithApp.append(newContact)
                                    self.contactsTable.reloadData()
                                }
                            } else {
                                print("Error retrieving data: \(error) \(error!.userInfo)")
                            }
                            
                        }
                    }
                }
            }
            self.contactsTable.reloadData()
        } catch {
            print("error accessing contacts")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rendezvousButtonPressed(sender: UIButton) {
        // 1) Get Selected User
        var contactUsername = ""
        print(selectedCell)
        if let cell = selectedCell {
            let selectedContactName = cell.textLabel!.text
            for contact in contactsWithApp {
                if contact.fullname == selectedContactName {
                    contactUsername = contact.rUsername
                    print(contactUsername)
                }
            }
        }
        
        // 2) Send them a request to Rendezvous
        // First get user based on the username
        let query = PFUser.query()
        query?.whereKey("username", equalTo: contactUsername)
        
        let instQuery = PFInstallation.query()
        instQuery?.whereKey("user", matchesQuery: query!)
        let message = "\(PFUser.currentUser()!.username!) wants to Rendezvous"
        let data: NSDictionary = ["message": message, "location": CurrentUser.user.location]
        let push = PFPush()
        push.setQuery(instQuery!)
        let geoLocation = PFGeoPoint(location: CurrentUser.user.location)
        push.setData(["alert": message, "location": geoLocation])
        push.sendPushInBackground()
        
        // show confirmation
        let alert = UIAlertController(title: "Request Sent!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "hideAlert", userInfo: nil, repeats: false)
        
    }
    
    func hideAlert() {
        self.dismissViewControllerAnimated(true, completion: nil)
        let view = self.storyboard?.instantiateViewControllerWithIdentifier("mainView")
        self.showViewController(view! as UIViewController, sender: view)
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
        
        if let contactsArray = self.contactsWithApp {
            count = contactsArray.count
        } else {
            count = 0
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.contactsWithApp[indexPath.item].fullname
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.contactsTable.cellForRowAtIndexPath(indexPath)
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
