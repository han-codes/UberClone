//
//  RiderViewController.swift
//  Uber
//
//  Created by Hannie Kim on 8/3/18.
//  Copyright © 2018 Hannie Kim. All rights reserved.
//

import UIKit
import MapKit

class RiderViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func callUberTapped(_ sender: UIButton) {
    }
    
}
