//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by Hannie Kim on 8/7/18.
//  Copyright © 2018 Hannie Kim. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

// Goal: Have rider request on the map, let driver select the ride they want to accept, then launch Apple Maps
class AcceptRequestViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // set a region
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: false )
        
        // make an annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        // add annotation to map
        map.addAnnotation(annotation)
    }
    
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        // Update the ride request
        // Querying for the right ride request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude, "driverLon":self.driverLocation.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        // Give directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        
        // makes sure the location we request is valid
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemark, error) in
            if let placemarks = placemark {
                // if something is in the placemarks array
                if placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = requestEmail
                    
                    // saying it's in driving mode
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
}
