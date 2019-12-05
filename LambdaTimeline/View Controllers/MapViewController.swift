//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by macbook on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Chacking if location services are even permited in the entire device
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // setup location manager
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have tot urn this on
        }
    }
    
    //Check if WE have permission to use location in THIS app
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse :  // uses location only when the app is open  <- prefferable
            //do map stuff
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // asking fro permission
        case .restricted: // not allowed beacuse of something like parental control
            // show alert letting know whats up
            break
        case .denied:
            //show alert instructing them how to turn on permission
            break
        case .authorizedAlways: //  uses location even if the app is in the backgroud
            break
        @unknown default:
            break
        }
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Later..
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // later
    }
}
