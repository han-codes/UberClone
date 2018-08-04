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
            }
        }
    }
    
    // when location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // gets coordinate of the user. Can access longitude and latitude from t
        if let coordinate = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            // used in callUberTapped method
            userLocation = center
            
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
    
    @IBAction func callUberTapped(_ sender: UIButton) {
        
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
                
                // the child RideRequests in our database, gets it's values set by let rideRequestDictionary
                // childByAutoId() will provide the random unique id
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                
                // set to true since they clicked on to call the uber
                uberHasBeenCalled = true
                
                // change the text of the button to give user option to cancel the uber
                callAnUberButton.setTitle("Cancel Uber", for: .normal)
            }
        }
        
        
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        // sign out of app
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
}
