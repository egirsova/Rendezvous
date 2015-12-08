//
//  ViewController.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/3/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

class CurrentUser {
    struct user {
        static var pfUser = PFUser.currentUser()
        static var location: CLLocation = CLLocation()
    }
}

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var passTF: UITextField!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.hidden = true
        errorLabel.hidden = true
        self.usernameTF.delegate = self
        self.passTF.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        errorLabel.hidden = true
        self.spinner.hidden = false
        self.spinner.startAnimating()
        PFUser.logInWithUsernameInBackground(usernameTF.text!, password: passTF.text!) { user, error in
            if user != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let mainView: UIViewController = storyboard.instantiateViewControllerWithIdentifier("mainView") as UIViewController
                self.presentViewController(mainView, animated: true, completion: nil)
            } else {
                self.spinner.stopAnimating()
                self.spinner.hidden = true
                self.errorLabel.hidden = false
                print("error: \(error) \(error!.userInfo)")
            }
        }
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let mainView: UIViewController = storyboard.instantiateViewControllerWithIdentifier("signUpView") as UIViewController
        self.presentViewController(mainView, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

