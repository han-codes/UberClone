//
//  RiderViewController.swift
//  Uber
//
//  Created by Hannie Kim on 8/3/18.
//  Copyright © 2018 Hannie Kim. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    // need CLLocationManager() to get location
    var locationManager = CLLocationManager()
    
    // used to set value of lon and lat for our database in callUberTpped
    var userLocation = CLLocationCoordinate2D()
    
    // will keep track if user has clicked to call an uber or not
    var uberHasBeenCalled = false
    
    var driverLocation = CLLocationCoordinate2D()
    
    var driverOnTheWay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegate to self, best accuracy, request authorization when location is in use, start to update the location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // if user is already signed in and has called an uber, which adds their data into our database
        // if their info in our database, they have already requested an uber so we know to give a cancel option
        if let email = Auth.auth().currentUser?.email {
            // Remove the user's values since they cancelled their uber
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                //                snapshot.ref.removeValue()
                self.uberHasBeenCalled = true
                self.callAnUberButton.setTitle("Cancel Uber", for: .normal)
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                // if there is a driverLat and driverLon value, this rider is getting picked up
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                            // getting the driver's location so we can let the rider know how far away the driver is
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            
                            // see if there's been an update with the driver
                            // we don't end the observer cause we always want to know of changes here
                            if let email = Auth.auth().currentUser?.email {
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                                    // if there is a driverLat and driverLon value, this rider is getting picked up
                                    if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                                        if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                                            if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                                // getting the driver's location so we can let the rider know how far away the driver is
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                self.driverOnTheWay = true
                                                self.displayDriverAndRider()
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    // displays the rounded distance in km the driver is from the rider
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation)
        let roundedDistance = round(distance * 100) / 100
        callAnUberButton.setTitle("Your driver is \(roundedDistance)km away!", for: .normal)
        // Removes all annotations so the previous ones aren't displayed
        map.removeAnnotations(map.annotations)
        
        // delta for our region. Absolute value since we only want positive numbers
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        // Create a region
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        
        // set rider annotations
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = userLocation
        riderAnnotation.title = "Your Location"
        map.addAnnotation(riderAnnotation)
        
        // set driver annotations
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Your Driver"
        map.addAnnotation(driverAnnotation)
    }
    
    // when location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // gets coordinate of the user. Can access longitude and latitude from t
        if let coordinate = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            // used in callUberTapped method
            userLocation = center
            
            // if uber has been called, display the driver and rider. Will now let us see both annotations for driver and rider
            if uberHasBeenCalled {
                displayDriverAndRider()
                
            } else {
                // define the region and how much space it should show using Span
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                // update map with our region
                map.setRegion(region, animated: true)
                
                // remove annotations before setting new ones, so the previous ones aren't saved
                map.removeAnnotations(map.annotations)
                
                // Pin to represent the user's location
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your Location"
                map.addAnnotation(annotation)
            }
            
            
        }
    }
    
    @IBAction func callUberTapped(_ sender: UIButton) {
        // if driver is on the way we don't want anything to happen
        // if driver is not on the way, give it the option to call an uber
        if !driverOnTheWay {
            // gets the current user's email address
            if let email = Auth.auth().currentUser?.email {
                if uberHasBeenCalled {
                    uberHasBeenCalled = false
                    callAnUberButton.setTitle("Call an Uber", for: .normal)
                    
                    // Remove the user's values since they cancelled their uber
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                        snapshot.ref.removeValue()
                        Database.database().reference().child("RideRequests").removeAllObservers()
                    }
                } else {
                    // dictionary will be passed into the RideRequests table
                    let rideRequestDictionary : [String:Any] = ["email":email, "lat":userLocation.latitude, "lon":userLocation.longitude]
                    
                    // the child RideRequests in our database, gets it's values set by rideRequestDictionary constant
                    // childByAutoId() will provide the random unique id
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                    
                    // set to true since they clicked on to call the uber
                    uberHasBeenCalled = true
                    
                    // change the text of the button to give user option to cancel the uber
                    callAnUberButton.setTitle("Cancel Uber", for: .normal)
                }
            }
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        // sign out of app
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
