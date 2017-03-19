//
//  ViewController.swift
//  Memorable Places
//
//  Created by Jafar Yormahmadzoda on 18/03/2017.
//  Copyright © 2017 Jafar Yormahmadzoda. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creating long press gesture
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 2
        // Adding the above gesture to the map
        map.addGestureRecognizer(uilpgr)
        
        if activePlace == -1 { // We clicked Add Button
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        } else {
            if places.count > activePlace {
                if let name = places[activePlace]["name"],
                    let lat = places[activePlace]["lat"],
                    let lot = places[activePlace]["lon"],
                    let latitude = Double(lat),
                    let longitude = Double(lot)
                {
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    
                    self.map.setRegion(region, animated: true)
                    // Annotaion is pin with label
                    let annotaion = MKPointAnnotation()
                    annotaion.coordinate = coordinate
                    annotaion.title = name
                    self.map.addAnnotation(annotaion)
                }
            }
        }
    }
    
    func longpress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: self.map)
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            
            let location = CLLocation(latitude:  newCoordinate.latitude, longitude: newCoordinate.longitude)
            var title = ""
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let placemark =  placemarks?[0] {
                        if placemark.subThoroughfare != nil {
                            title += placemark.subThoroughfare! + ""
                        }
                        if placemark.thoroughfare != nil {
                            title += placemark.thoroughfare!
                        }
                    }
                }
                // If we had problem with internet connection
                if title == "" {
                    title = "Added \(NSDate())"
                }
                
                // Creating annotaion
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = title
                self.map.addAnnotation(annotation)
                
                // Adding this places to our list
                places.append(["name": title, "lat": String(newCoordinate.latitude), "lon": String(newCoordinate.longitude)])
                // Updating permanent storage
                UserDefaults.standard.set(places, forKey: "places")
            })
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

