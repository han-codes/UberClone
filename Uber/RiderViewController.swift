//
//  RiderViewController.swift
//  Uber
//
//  Created by Hannie Kim on 8/3/18.
//  Copyright © 2018 Hannie Kim. All rights reserved.
//

import UIKit
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    // need CLLocationManager() to get location
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegate to self, best accuracy, request authorization when location is in use, start to update the location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // when location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // gets coordinate of the user. Can access longitude and latitude from t
        if let coordinate = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
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

    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func callUberTapped(_ sender: UIButton) {
    }
    
}
