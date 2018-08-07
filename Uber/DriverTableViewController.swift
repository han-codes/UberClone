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

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    // hold the ride requests in DataSnapshot type
    // snapshot used in viewDidLoad is a DataSnapshot data type
    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()   // stores the driver's location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate to self, best accuracy, request authorization when location is in use, start to update the location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            // puts snapshot into a dictionary
            if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                // checks to see if there's a driverLat value inside of the snapshot
                // if there is, that means a driver has requested that rider already, since it has the driver's latitude
                if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                    
                } else {    // if there isn't a driverLat value for the rider
                    // add the snapshot to our array that holds all of them
                    self.rideRequests.append(snapshot)
                    // refresh every time we add something new.
                    self.tableView.reloadData()
                    
                }
            }
            
        }
        
        // Reloads the driver table view every 3 seconds. So it will keep updating  the distance from driver and rider
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    // when the driver's location updates, set the coordinates inside the driverLocation variable
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
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
                if let lat = rideRequestDictionary["lat"] as? Double {
                    if let lon = rideRequestDictionary["lon"] as? Double {
                        
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        // get the distance from driverCLLocation and riderCLLocation
                        // it does the calculations for us. 
                        // Divide by 1000 to convert the number to kilometers
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        
                        // get the rounded value of distance and times 100 to get a decimal value
                        let roundedDistance = round(distance * 100) / 100
                        
                        //
                        cell.textLabel?.text = "\(email) - \(roundedDistance) km away"
                    }
                }
                
            }
        }
        
        return cell
    }
    
    // When driver selects a cell, it'll go to the AcceptRequest View Controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // gets the snapshot for the specific row
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController {
            if let snapshot = sender as? DataSnapshot {
                // gets the emails of the users in the database and displays the the cells
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let email = rideRequestDictionary["email"] as? String {
                        // gets latitude and longitude from the database snapshot
                        if let lat = rideRequestDictionary["lat"] as? Double {
                            if let lon = rideRequestDictionary["lon"] as? Double {
                                // set properties from our AcceptRequestViewController
                                acceptVC.requestEmail = email
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                acceptVC.requestLocation = location
                                acceptVC.driverLocation = driverLocation
                            }
                        }
                    }
                }
            }
        }
    }
}
