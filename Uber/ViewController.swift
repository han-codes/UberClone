//
//  ViewController.swift
//  Uber
//
//  Created by Hannie Kim on 8/2/18.
//  Copyright © 2018 Hannie Kim. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {
    
    var signUpMode = true
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBAction func topTapped(_ sender: UIButton) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "You must provide both a valid email and password")
        } else {
            if let email = emailTextField.text {
                if let password = passwordTextField.text {
                    if signUpMode {
                        // SIGN UP AUTHENTICATION
                        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                            if error != nil {
                                // display error message
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                
                                // Sets the displayName for user, whether driver or rider
                                if self.riderDriverSwitch.isOn {
                                    // DRIVER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                } else {
                                    // RIDER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                    
                                    // When log in is successful, go to Navigation Controller for the rider
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }                                
                            }
                        }
                    } else {
                        // LOG IN
                        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                            if error != nil {
                                // display error message
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                // if the user's displayName is...
                                if user?.user.displayName == "Driver" {
                                    // DRIVER
                                    print("Driver")
                                } else {
                                    // RIDER
                                    // When log in is successful, go to Navigation Controller for the rider
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                            }
                        }
                    }
                }
            }
            
            
        }
    }
    
    @IBAction func bottomTapped(_ sender: UIButton) {
        if signUpMode {
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            riderLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            driverLabel.isHidden = true
            signUpMode = false
        } else {
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            riderLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            driverLabel.isHidden = false
            signUpMode = true
        }
    }
    
    // our custom method for displaying alerts
    func displayAlert(title: String, message: String) {
        
        // Creates the Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // The action button to alertController
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        // presents the AlertController we just made
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

