//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Hannie Kim on 8/4/18.
//  Copyright © 2018 Hannie Kim. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class DriverTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        // sign out of app
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        cell.textLabel?.text = "Hello"
        
        return cell
    }
}
