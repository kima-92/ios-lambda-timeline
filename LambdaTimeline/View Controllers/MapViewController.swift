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
    let regionInMeters: Double = 10_000

    @IBOutlet weak var mapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // zoom in to user's are by regionInMeters
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
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
            mapView.showsUserLocation = true //puts the blue dot where the user is
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation() // to update location as it moves
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
    
    // This func runs every time the user moves (re-locates)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        
        mapView.setRegion(region, animated: true)
    }
    
    //This runs everytime the authirization changes. (If user did or not give permission)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        checkLocationAuthorization()
    }
}
