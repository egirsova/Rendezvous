//
//  SignUpViewController.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/3/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var phoneTF: UITextField!
    @IBOutlet var passTF: UITextField!
    @IBOutlet var confirmPassTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTF.delegate = self
        self.phoneTF.delegate = self
        self.passTF.delegate = self
        self.confirmPassTF.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {

        // First check if password matches
        if passTF.text == confirmPassTF.text {
            let user = PFUser()
            
            user.username = usernameTF.text!
            user.email = emailTF.text!
            user.password = passTF.text!
            user.setObject(phoneTF.text!, forKey:"phone")
            
            // Send to cloud
            user.signUpInBackgroundWithBlock { (succeed, error) -> Void in
                if succeed {
                    print("Sign up successful")
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let mainView: UIViewController = storyboard.instantiateViewControllerWithIdentifier("mainView") as UIViewController
                    self.presentViewController(mainView, animated: true, completion: nil)
                } else {
                    print("Error: \(error) \(error!.userInfo)")
                }
            }
        } else {
            print("password doesn't match")
        }
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

extension SignUpViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
