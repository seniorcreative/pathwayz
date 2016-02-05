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
import CloudKit

class MapViewController: UIViewController, CLLocationManagerDelegate, AddSavedPinsViewControllerDelegate, MKMapViewDelegate {

    
    
    // Prototyping -
    
    // Design in Sketch, import into Flinto
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
//    @IBOutlet weak var latField: UITextField!
//    @IBOutlet weak var longField: UITextField!
    
    @IBOutlet weak var locationCount: UITextField!
    
    @IBOutlet weak var accuracyField: UITextField!
    @IBOutlet weak var speedField: UITextField!
    @IBOutlet weak var scaleField: UITextField!
    
    @IBOutlet weak var buttonSaveLocation: UIButton!
    
//    @IBOutlet weak var buttonLocationDone: UIButton!
    
    @IBOutlet weak var pinImage: UIImageView!
    
    @IBOutlet weak var addPinContainer: UIView!
    
    // Constants
    
    
    let regionRadius: CLLocationDistance = 50
    
    var myLocations: [CLLocationCoordinate2D] = []
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var currentZoomScale : MKZoomScale? = 1
    
    var savedPins = [SavedPin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if CLLocationManager.locationServicesEnabled() {
                
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.startUpdatingLocation()
//                self.locationManager.startUpdatingHeading()
//                self.locationManager.startMonitoringSignificantLocationChanges()
                self.locationManager.distanceFilter = 10
            
                //self.mapView setup to show user location
                self.mapView.delegate = self
                self.mapView.showsUserLocation = true
                self.mapView.showsScale = true
                //
                self.mapView.mapType = MKMapType(rawValue: 0)!
                self.mapView.userTrackingMode = MKUserTrackingMode.Follow
//                self.mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!

        }
        
        
        buttonSaveLocation.backgroundColor = UIColor.yellowColor()
        buttonSaveLocation.setTitleColor(UIColor.grayColor(), forState: .Normal)
        buttonSaveLocation.layer.cornerRadius = buttonSaveLocation.layer.visibleRect.height / 2
    
        
    }
    
    
    /// Custom methods
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)

        self.mapView.setRegion(coordinateRegion, animated: true)
        
//        self.locationManager.stopUpdatingLocation()
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        print("updated to location \(newLocation) from \(oldLocation)")
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")

        
        // check for reading of accuracy, and reachability and only use location based on satisfaction of rules.

         let locValue:CLLocationCoordinate2D = locations[0].coordinate
//         self.latField.text = String(locValue.latitude)
//         self.longField.text = String(locValue.longitude)
        
        self.speedField.text = String(locations[0].speed)
        self.accuracyField.text = String(locations[0].horizontalAccuracy)

        
        if (locations[0].horizontalAccuracy <= 75.0)
        {

             myLocations.append(locValue)
     
        }
        
        if(self.mapView.overlays.count > 0)
        {
            self.mapView.removeOverlay(self.mapView.overlays[0])
            
        }
        
        self.locationCount.text = String(self.myLocations.count)
        
        let polyline = MKPolyline(coordinates: &myLocations, count: self.myLocations.count)
        self.mapView.addOverlay(polyline)
        
        
        
        
        if(self.myLocations.count < 1)
        {
            centerMapOnLocation(manager.location!)
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error in location manager \(error)")
        
    }

    @IBAction func savePin(sender: AnyObject) {
        
        self.pinImage.hidden = false
//        self.buttonLocationDone.hidden = false
        centerMapOnLocation(locationManager.location!)
        
        let destinationVC = self.childViewControllers[0] as? AddSavedPinViewController
        destinationVC?.delegate = self
        
        addPinContainer.hidden = false
        
        
    }
    
    /*
    func data_request()
    {
        let url:NSURL = NSURL(string: url_to_request)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "data=Hello"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let ​_:NSData = data, let _​:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
            
        }
        
        task.resume()
        
    }
    */
    
    
    @IBAction func pinSaved(sender: AnyObject) {
        
        self.pinImage.hidden = true
//        self.buttonLocationDone.hidden = true

//        var Stream : NSOutputStream

        var locationsObject : NSMutableArray = []
        
        for var location : CLLocationCoordinate2D in myLocations
        {
            var locationDict : NSDictionary = ["lat": location.latitude, "long": location.longitude]
            
            locationsObject.addObject(locationDict)
        }
        
        
        do
        {
            
//            let wrappedDict : NSDictionary = ["Data" : locationsObject]
            
            let dataExample : NSData = NSKeyedArchiver.archivedDataWithRootObject(locationsObject)
//            
//            var jsonString = try NSJSONSerialization.JSONObjectWithData(locationsObject!, options: NSJSONReadingOptions)(locationsObject, options: .PrettyPrinted)
            
//            let string = NSString(data: jsonString!, encoding: NSUTF8StringEncoding)
            
            
            
            
            let url:NSURL = NSURL(string: "http://seniorcreative.com/data/testpost.php")!
            let session = NSURLSession.sharedSession()
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
            
//            let paramString = "data=Hello"
            
//            print(dataExample)
            print(locationsObject)
            
            request.HTTPBody = dataExample // paramString.dataUsingEncoding(NSUTF8StringEncoding)
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")

            
            let task = session.dataTaskWithRequest(request) {
                (
                let data, let response, let error) in
                
                guard let ​_:NSData = data, let _​:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(dataString)
                
            }
            
            task.resume()
            
//            var dictionaryExample : [String:AnyObject] = ["user":"UserName", "pass":"password", "token":"0123456789", "image":0] // image should be either NSData or empty
//            let dataExample : NSData = NSKeyedArchiver.archivedDataWithRootObject(dictionaryExample)
//            let dictionary:NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(dataExample)! as NSDictionary
            
            
        }
        catch
        {
            
        }
    
        
        
        
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        let savedPin = view.annotation as! SavedPin
//        stopMonitoringGeotification(geotification)
//        removeGeotification(geotification)
//        saveAllGeotifications()
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor(colorLiteralRed: 0/255, green: 204/255, blue: 204/255, alpha: 0.7)
      
            
            pr.lineWidth = 7 // 20 * self.currentZoomScale!
            pr.alpha = 0.7
            return pr
        } else if (overlay is MKCircle) {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purpleColor()
            circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
            return circleRenderer
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
    
    
    // MARK: AddSavedPinViewControllerDelegate
    
    //  func addSavedPinViewController(controller: AddSavedPinViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
    //    controller.dismissViewControllerAnimated(true, completion: nil)
    //    // Add SavedPin
    //    let SavedPin = SavedPin(coordinate: coordinate, radius: radius, identifier: identifier, note: note, eventType: eventType)
    //    addSavedPin(SavedPin)
    //    saveAllSavedPins()
    //  }
    
    func addSavedPinViewController(controller: AddSavedPinViewController, radius: Double, identifier: String, note: String, eventType: EventType) {
        
        let coordinate = mapView.centerCoordinate
        
        
        self.pinImage.hidden = true
//        self.buttonLocationDone.hidden = true
        self.addPinContainer.hidden = true
        
//        controller.dismissViewControllerAnimated(true, completion: nil)
        // 1
        let clampedRadius = (radius > locationManager.maximumRegionMonitoringDistance) ? locationManager.maximumRegionMonitoringDistance : radius
        
        let savedPin = SavedPin(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        
        addSavedPin(savedPin)
        // 2
        startMonitoringSavedPin(savedPin)
        
//        saveAllSavedPins()
    }
    
    func regionWithSavedPin(savedPin: SavedPin) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: savedPin.coordinate, radius: savedPin.radius, identifier: savedPin.identifier)
        // 2
        region.notifyOnEntry = (savedPin.eventType == .OnEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoringSavedPin(savedPin: SavedPin) {
        // 1
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: self)
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            showSimpleAlertWithTitle("Warning", message: "Your pin is saved but will only be activated once you grant Pathwayz permission to access the device location.", viewController: self)
        }
        // 3
        let region = regionWithSavedPin(savedPin)
        // 4
        locationManager.startMonitoringForRegion(region)
    }
    
    func addSavedPin(savedPin : SavedPin)
    {
        savedPins.append(savedPin)
        mapView.addAnnotation(savedPin)
        addRadiusOverlayForSavedPin(savedPin)
    }

    
    func addRadiusOverlayForSavedPin(savedPin: SavedPin) {
        mapView.addOverlay(MKCircle(centerCoordinate: savedPin.coordinate, radius: savedPin.radius))
    }
//    
//    func addGeotification(geotification: Geotification) {
//        saved.append(geotification)
//        mapView.addAnnotation(geotification)
//        addRadiusOverlayForGeotification(geotification)
//        updateGeotificationsCount()
//    }
    

}

