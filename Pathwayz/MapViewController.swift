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




let kSavedItemsKey      = "savedPins"
let kSavedLocationsKey  = "savedLocations"

class MapViewController: UIViewController, CLLocationManagerDelegate, AddSavedPinsViewControllerDelegate, MKMapViewDelegate {

    
    
    // Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
//    @IBOutlet weak var locationCount: UITextField!
//    @IBOutlet weak var accuracyField: UITextField!
//    @IBOutlet weak var speedField: UITextField!
//    @IBOutlet weak var scaleField: UITextField!
    
    @IBOutlet weak var btnAddPin: UIButton!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var addPinContainer: UIView!
    
    // Constants
    
    let regionRadius: CLLocationDistance = 50
    let locationManager:CLLocationManager = CLLocationManager()
    
    // Vars
    
    var myLocations: [CLLocationCoordinate2D] = []
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
        
        
        btnAddPin.backgroundColor = UIColor.yellowColor()
        btnAddPin.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnAddPin.layer.cornerRadius = btnAddPin.layer.visibleRect.height / 2
    
    
        loadAllPins()
        loadAllLocations()
        
        
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
        
//        self.speedField.text = String(locations[0].speed)
//        self.accuracyField.text = String(locations[0].horizontalAccuracy)

        
        if (locations[0].horizontalAccuracy <= 75.0)
        {

            myLocations.append(locValue)
            
            saveAllLocations()
     
        }
        
        if(self.mapView.overlays.count > 0)
        {
            for overlay in self.mapView.overlays
            {
                let overlayType = overlay as? MKPolyline
                
                if (overlayType != nil)
                {
                    self.mapView.removeOverlay(overlay)
                }
            }
            
            // self.mapView.removeOverlay(self.mapView.overlays[0])
            
        }
        
//        self.locationCount.text = String(self.myLocations.count)
        
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

    @IBAction func showAddPinVC(sender: AnyObject) {
        
        self.pinImage.hidden = false
        centerMapOnLocation(locationManager.location!)
        
        let destinationVC = self.childViewControllers[0] as? AddSavedPinViewController
        destinationVC?.delegate = self

        addPinContainer.alpha = 0.0
        addPinContainer.frame.origin.y = -300
        addPinContainer.hidden = false
        
        btnAddPin.enabled = false
       
        UIView.animateWithDuration(0.5, delay: 0.1, options: [.CurveEaseInOut], animations: {
            self.addPinContainer.frame.origin.y = 80
            self.addPinContainer.alpha = 1.0
        }, completion: nil)
        
    }
    
    func hideAddPinVC()
    {
        
        
        UIView.animateWithDuration(0.5, delay: 0.1, options: [.CurveEaseInOut], animations: {
            self.addPinContainer.frame.origin.y = -300
            self.addPinContainer.alpha = 0.0
            },
            completion: {
                (finished: Bool) in
                if (finished)
                {
//                    print("animation out finished")
                    self.addPinContainer.hidden = true
                    self.btnAddPin.enabled = true
                }
            }
            
            
         )
        
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
    
    
//    @IBAction func pinSaved(sender: AnyObject) {
//        
//        self.pinImage.hidden = true
////        self.buttonLocationDone.hidden = true
//
////        var Stream : NSOutputStream
//
//        var locationsObject : NSMutableArray = []
//        
//        for var location : CLLocationCoordinate2D in myLocations
//        {
//            var locationDict : NSDictionary = ["lat": location.latitude, "long": location.longitude]
//            
//            locationsObject.addObject(locationDict)
//        }
//        
//        
//        do
//        {
//            
////            let wrappedDict : NSDictionary = ["Data" : locationsObject]
//            
//            let dataExample : NSData = NSKeyedArchiver.archivedDataWithRootObject(locationsObject)
////            
////            var jsonString = try NSJSONSerialization.JSONObjectWithData(locationsObject!, options: NSJSONReadingOptions)(locationsObject, options: .PrettyPrinted)
//            
////            let string = NSString(data: jsonString!, encoding: NSUTF8StringEncoding)
//            
//            
//            
//            
//            let url:NSURL = NSURL(string: "http://seniorcreative.com/data/testpost.php")!
//            let session = NSURLSession.sharedSession()
//            
//            let request = NSMutableURLRequest(URL: url)
//            request.HTTPMethod = "POST"
//            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
//            
////            let paramString = "data=Hello"
//            
////            print(dataExample)
//            print(locationsObject)
//            
//            request.HTTPBody = dataExample // paramString.dataUsingEncoding(NSUTF8StringEncoding)
////            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
////            request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//            
//            let task = session.dataTaskWithRequest(request) {
//                (
//                let data, let response, let error) in
//                
//                guard let ​_:NSData = data, let _​:NSURLResponse = response  where error == nil else {
//                    print("error")
//                    return
//                }
//                
//                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                print(dataString)
//                
//            }
//            
//            task.resume()
//            
////            var dictionaryExample : [String:AnyObject] = ["user":"UserName", "pass":"password", "token":"0123456789", "image":0] // image should be either NSData or empty
////            let dataExample : NSData = NSKeyedArchiver.archivedDataWithRootObject(dictionaryExample)
////            let dictionary:NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(dataExample)! as NSDictionary
//            
//            
//        }
//        catch
//        {
//            
//        }
//    
//        
//    }
    
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "mySavedPin"
        if annotation is SavedPin {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .Custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteSavedPin")!, forState: .Normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete savedPin
        let savedPin = view.annotation as! SavedPin
        stopMonitoringSavedPin(savedPin)
        removeSavedPin(savedPin)
        saveAllPins()
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
//        self.scaleField.text = String(currentZoomScale!)
    }
    
    
    // MARK: AddSavedPinViewControllerDelegate
    
    func addSavedPinViewController(controller: AddSavedPinViewController, radius: Double, identifier: String, note: String, eventType: EventType) {
        
        let coordinate = mapView.centerCoordinate
        
        
        self.pinImage.hidden = true
//        self.buttonLocationDone.hidden = true
//        self.addPinContainer.hidden = true
        
//        controller.dismissViewControllerAnimated(true, completion: nil)
        // 1
        let clampedRadius = (radius > locationManager.maximumRegionMonitoringDistance) ? locationManager.maximumRegionMonitoringDistance : radius
        
        let savedPin = SavedPin(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        
        addSavedPin(savedPin)
        // 2
        startMonitoringSavedPin(savedPin)
        
        //3
        saveAllPins()
        
        //4 
        hideAddPinVC()
    }
    
    // MARK: Loading and saving functions
    
    
    
        // PINS
        
        func loadAllPins() {
            savedPins = []
            
            if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
                for savedItem in savedItems {
                    if let savedPin = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? SavedPin {
                        addSavedPin(savedPin)
                    }
                }
            }
        }
        
        func saveAllPins() {
            let items = NSMutableArray()
            for savedPin in savedPins {
                let item = NSKeyedArchiver.archivedDataWithRootObject(savedPin)
                items.addObject(item)
            }
            NSUserDefaults.standardUserDefaults().setObject(items, forKey: kSavedItemsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    
        // LOCATIONS
    
    
        func loadAllLocations() {
            myLocations = []
            
            if let savedLocations = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedLocationsKey) {
                for savedLocation in savedLocations {
                
//                    print("Got a location that was saved \(savedLocation)")
                    
                    if let savedLocation = NSKeyedUnarchiver.unarchiveObjectWithData(savedLocation as! NSData) as? NSDictionary {
                        
                        let lat = savedLocation["lat"] as? Double
                        let long = savedLocation["long"] as? Double
                        
                        if (lat != nil && long != nil)
                        {
                        
                            let locationItem : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                            
                            myLocations.append(locationItem)
                            
                        }
                    }
                }
            }
        }
        
        func saveAllLocations() {
            let locations = NSMutableArray()
            for locationItem in myLocations {
                
                let locationItemAsObject : NSDictionary = ["lat" : locationItem.latitude, "long" : locationItem.longitude]
                let location = NSKeyedArchiver.archivedDataWithRootObject(locationItemAsObject)
                locations.addObject(location)
            }
            NSUserDefaults.standardUserDefaults().setObject(locations, forKey: kSavedLocationsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    
    
    
    
    
    ///
    
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
    
    func stopMonitoringSavedPin(savedPin: SavedPin) {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == savedPin.identifier {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    
    func addSavedPin(savedPin : SavedPin)
    {
        savedPins.append(savedPin)
        mapView.addAnnotation(savedPin)
        addRadiusOverlayForSavedPin(savedPin)
    }
    
    func removeSavedPin(savedPin: SavedPin) {
        if let indexInArray = savedPins.indexOf(savedPin) {
            savedPins.removeAtIndex(indexInArray)
        }
        
        mapView.removeAnnotation(savedPin)
        removeRadiusOverlayForSavedPin(savedPin)
//        updateGeotificationsCount()
    }

    
    func addRadiusOverlayForSavedPin(savedPin: SavedPin) {
        mapView.addOverlay(MKCircle(centerCoordinate: savedPin.coordinate, radius: savedPin.radius))
    }
    
    func removeRadiusOverlayForSavedPin(savedPin: SavedPin) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        if let overlays = mapView?.overlays {
            for overlay in overlays {
                if let circleOverlay = overlay as? MKCircle {
                    let coord = circleOverlay.coordinate
                    if coord.latitude == savedPin.coordinate.latitude && coord.longitude == savedPin.coordinate.longitude && circleOverlay.radius == savedPin.radius {
                        mapView?.removeOverlay(circleOverlay)
                        break
                    }
                }
            }
        }
    }
    

}

