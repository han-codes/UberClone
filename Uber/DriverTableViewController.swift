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
import MapKit

class DriverTableViewController: UITableViewController {

    // hold the ride requests in DataSnapshot type
    // snapshot used in viewDidLoad is a DataSnapshot data type
    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()   // stores the driver's location
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            // add the snapshot to our array that holds all of them
            self.rideRequests.append(snapshot)
            // refresh every time we add something new.
            self.tableView.reloadData()
        }
    }
   
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequests.count
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        // sign out of app
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        // gets the snapshot for the specific row
        let snapshot = rideRequests[indexPath.row]
        
        // gets the emails of the users in the database and displays the the cells
        if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
            if let email = rideRequestDictionary["email"] as? String {
                    cell.textLabel?.text = email
            }
        }
        
        return cell
    }
}
