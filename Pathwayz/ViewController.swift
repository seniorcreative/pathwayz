//
//  ViewController.swift
//  Pathwayz
//
//  Created by Steven Smith on 24/01/2016.
//  Copyright © 2016 Steven Smith. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    
    // Prototyping - 
    
    // Design in Sketch, import into Flinto
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var latField: UITextField!
    @IBOutlet weak var longField: UITextField!
    
    @IBOutlet weak var accuracyField: UITextField!
    @IBOutlet weak var speedField: UITextField!
    @IBOutlet weak var scaleField: UITextField!
    
    
    // Constants
    
    
    let regionRadius: CLLocationDistance = 20
    
    var myLocations: [CLLocationCoordinate2D] = []
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var currentZoomScale : MKZoomScale? = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        if CLLocationManager.locationServicesEnabled() {
                
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.locationManager.startUpdatingLocation()
//                self.locationManager.startUpdatingHeading()
//                self.locationManager.startMonitoringSignificantLocationChanges()
                self.locationManager.distanceFilter = 1
            
                //self.mapView setup to show user location
                self.mapView.delegate = self
                self.mapView.showsUserLocation = true
                self.mapView.showsScale = true
                self.mapView.mapType = MKMapType(rawValue: 0)!
                self.mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!

        }
    
        
    }
    
    
    /// Custom methods
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)

        self.mapView.setRegion(coordinateRegion, animated: true)
        
//        self.locationManager.stopUpdatingLocation()
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")

        
        // check for reading of accuracy, and reachability and only use location based on satisfaction of rules.

         let locValue:CLLocationCoordinate2D = locations[0].coordinate
         self.latField.text = String(locValue.latitude)
         self.longField.text = String(locValue.longitude)
        
        self.speedField.text = String(locations[0].speed)
        self.accuracyField.text = String(locations[0].horizontalAccuracy)

        
        if (locations[0].horizontalAccuracy <= 30.0)
        {

             myLocations.append(locValue)
     
             if(self.mapView.overlays.count > 0)
             {
             self.mapView.removeOverlay(self.mapView.overlays[0])
             }
            
             let polyline = MKPolyline(coordinates: &myLocations, count: self.myLocations.count)
            
                
             self.mapView.addOverlay(polyline)
            
        }
        
        
        
        if(self.myLocations.count < 1)
        {
            centerMapOnLocation(manager.location!)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error in location manager \(error)")
        
    }

    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor(colorLiteralRed: 0/255, green: 204/255, blue: 204/255, alpha: 0.7)
      
            
            pr.lineWidth = 10 * self.currentZoomScale!
            pr.alpha = 0.7
            return pr
        }
        else
        {
            return MKOverlayRenderer()
        }
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        
        // Calculate width of line based on map scale.
//        MKZoomScale currentZoomScale = map.bounds.size.width / map.visibleMapRect.size.width;
//        mapView.
        
        self.currentZoomScale = CGFloat(mapView.bounds.size.width) / CGFloat(mapView.visibleMapRect.size.width)
        
        self.scaleField.text = String(currentZoomScale!)
    }


}

