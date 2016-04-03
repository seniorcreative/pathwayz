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
import CoreData




let kSavedItemsKey      = "savedPins"
let kSavedLocationsKey  = "savedLocations"

class MapViewController: UIViewController, CLLocationManagerDelegate, AddSavedPinsViewControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate {

    @IBOutlet weak var iconBackground1: UIView!
    
    // Have this verbose line at the top for access to core data throughout app.
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var myStoredLocations : [LocationModel] = []
    
    @IBOutlet weak var liveSwitch: UISwitch!
    
    var lineColor: NSArray = [0,204,204]
    // Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
//    @IBOutlet weak var locationCount: UITextField!
//    @IBOutlet weak var accuracyField: UITextField!
//    @IBOutlet weak var speedField: UITextField!
//    @IBOutlet weak var scaleField: UITextField!
    
    @IBOutlet weak var btnAddPin: UIButton!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var addPinContainer: UIView!
    
    @IBOutlet weak var iconView1: UIView!
    @IBOutlet weak var IconView1Circ: UIView!
    @IBOutlet weak var iconNameLabel: UILabel!
    @IBOutlet weak var btnSync: UIBarButtonItem!
    
    
    // Constants
    
    let regionRadius: CLLocationDistance = 50
    let locationManager:CLLocationManager = CLLocationManager()
    
    let fileIO : FileIO = FileIO()
    
    // Vars
    
    var myLocations: [CLLocationCoordinate2D] = []
    var myLocationsFull: [CLLocation] = []
    var currentZoomScale : MKZoomScale? = 1
    var savedPins = [SavedPin]()
    
    

    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.yellowColor()
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "ShareTechMono-Regular", size: 18)!]
        
        
        if CLLocationManager.locationServicesEnabled() {
            
            
                // For more information on Location updates in foreground and background see:
                // https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html#//apple_ref/occ/instm/CLLocationManager/pausesLocationUpdatesAutomatically
            
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.startUpdatingLocation()
//                self.locationManager.startUpdatingHeading()
                self.locationManager.startMonitoringSignificantLocationChanges()
                self.locationManager.pausesLocationUpdatesAutomatically = true
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
        
        
        btnAddPin.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 255/255, blue: 0/255, alpha: 0.9)
        btnAddPin.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnAddPin.layer.cornerRadius = btnAddPin.layer.visibleRect.height / 2
    
    
        loadAllPins()
//        loadAllLocations() //  NSKeyed Method
//        loadLocations() // Core Data Method (persistent)
        loadCloudKitLocations() // Cloud Kit Method (cloud)
        
        loadFriends()
        
        
        
        iconBackground1.layer.cornerRadius = iconBackground1.layer.visibleRect.height / 2
        
        
        // Position the name / colour icon outside so it can be ready to be moved in.
        var iconView1Frame = self.iconView1.frame
        iconView1Frame.origin.x = -99
        self.iconView1.frame = iconView1Frame
        
        
        
        
        prepopulateBridgeAlertPins()
        
        
        
        
        
        // Animate the icon in.
        UIView.animateWithDuration(0.4, delay: 2.0, options: .CurveEaseOut, animations: {
            
            var iconView1Frame = self.iconView1.frame
            iconView1Frame.origin.x += 100
            self.iconView1.frame = iconView1Frame
            
            }, completion: { finished in
                print("Icon moved in")
        })
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //
        
        if (NSUserDefaults.standardUserDefaults().arrayForKey("lineColor") != nil) {
            
            self.lineColor = NSUserDefaults.standardUserDefaults().arrayForKey("lineColor")! as NSArray
            
            let R = Float(self.lineColor[0] as! NSNumber)
            let G = Float(self.lineColor[1] as! NSNumber)
            let B = Float(self.lineColor[2] as! NSNumber)
            
            self.iconBackground1.backgroundColor = UIColor(colorLiteralRed: R/255, green: G/255, blue: B/255, alpha: 1.0)
            
        }
        else
        {
            // let's save that first line color.
            let defaultColor = [0,204,204]
            NSUserDefaults.standardUserDefaults().setObject(defaultColor, forKey: "lineColor")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        loadLocations()
        
        plotLocations()
        
        
        // Set name icon label
        
        setInitials()
            
    }
    
   
    
    /// Custom methods
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 10.0, regionRadius * 10.0)

        self.mapView.setRegion(coordinateRegion, animated: true)
        
//        self.locationManager.stopUpdatingLocation()
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
        // check for reading of accuracy, and reachability and only use location based on satisfaction of rules.
        let locValue:CLLocationCoordinate2D     = locations[0].coordinate
        let locTimeStamp:NSDate                 = locations[0].timestamp
        let locSpeed: CLLocationSpeed           = locations[0].speed
//        
//      print("got some location info \(locations[0])")
        
        if (locations[0].horizontalAccuracy <= 75.0)
        {
            
//            addLocation(locValue, localocTimeStamp, locSpeed)
            addLocation(locValue, atTime: locTimeStamp, andSpeed: locSpeed)
            
        }
        
        plotLocations()
       
        
    }
    
    
    func plotLocations()
    {
        
        
        let R = Float(self.lineColor[0] as! NSNumber)
        let G = Float(self.lineColor[1] as! NSNumber)
        let B = Float(self.lineColor[2] as! NSNumber)
        
        // Clear the line from the list of map overlays before drawing it again
        
        if(self.mapView.overlays.count > 0)
        {
            for overlay in self.mapView.overlays
            {
                let overlayLine = overlay as? MKPolyline
                
                if (overlayLine != nil)
                {
                    self.mapView.removeOverlay(overlay)
                }
            
                let overlayCircle = overlay as? MKCircle
                
                if (overlayCircle != nil)
                {
                    
//                    let circleRenderer = self.mapView.rendererForOverlay(overlayCircle!)
                    
//                    circleRenderer.
                    
//                  let circleRenderer = MKCircleRenderer(overlay: overlay)
//                    print("we got a circle \(overlayCircle)")
//                    overlayCircle.
//                    circleRenderer.lineWidth = 1.0
//                    overlayCircle.
                    
//                    circleRenderer
                    
//                    circleRenderer.strokeColor = UIColor(colorLiteralRed: R/255, green: G/255, blue: B/255, alpha: 0.7)
//                    circleRenderer.fillColor = UIColor(colorLiteralRed: R/255, green: G/255, blue: B/255, alpha: 0.4) //
//                    mapView(<#T##mapView: MKMapView##MKMapView#>, rendererForOverlay: <#T##MKOverlay#>)
                    
                    
                }
            }
            
        }
        
        // Now draw the line
        
        let polyline = MKPolyline(coordinates: &myLocations, count: self.myLocations.count)
        self.mapView.addOverlay(polyline)
        
        
        // Center if we're in the tracking mode (use the switch value under the nav bar)

        if (liveSwitch!.on)
        {
            centerMapOnLocation(locationManager.location!)
            self.locationManager.startUpdatingHeading()
        }
        else
        {
            
            self.locationManager.stopUpdatingHeading()
            
        }
        
        
    }
    
    // MARK : CORE DATA SAVING
    // We will save locally, but allow this data to be synced to cloudkit when the sync button is pressed.
    // I want to load this stuff back in when the app launches.
    
    func addLocation(locValue: CLLocationCoordinate2D, atTime: NSDate, andSpeed:CLLocationSpeed)
    {
        
        let insertedLocationItem = NSEntityDescription.insertNewObjectForEntityForName("LocationModel", inManagedObjectContext: self.managedObjectContext) as? LocationModel
        
        if (insertedLocationItem != nil)
        {
            
            insertedLocationItem?.lat       = locValue.latitude
            insertedLocationItem?.long      = locValue.longitude
            insertedLocationItem?.time      = atTime
            insertedLocationItem?.speed     = andSpeed
            
            do
            {
                try self.managedObjectContext.save()
                
                loadLocations()
            }
            catch
            {
                print("Error with saving locations into Core Data caught")
            }
            
        }
        
    }
    
    
    func loadLocations ()
    {
        
        
        // We will load in an array of Locations from the persistent core data store
        
        let fetchRequest = NSFetchRequest(entityName: "LocationModel")
        
        do
        {
            let myLocationsLoaded = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [LocationModel]
            
            if(myLocationsLoaded != nil)
            {
                
                var locationCoords : [CLLocationCoordinate2D] = []
                var tmpFullLocations : [CLLocation] = []
                
                for locationLoaded in myLocationsLoaded!
                {
                    
                    let tmpLocation: CLLocation = CLLocation(
                        coordinate: CLLocationCoordinate2D(latitude: Double(locationLoaded.lat!), longitude: Double(locationLoaded.long!)),
                        altitude: 0.0,
                        horizontalAccuracy: 0.0,
                        verticalAccuracy: 0.0,
                        course: 0.0,
                        speed: Double(locationLoaded.speed!),
                        timestamp: locationLoaded.time!)
                    
//                    print("got loaded location time \(locationLoaded.time)")
                    
                    //latitude: Double(locationLoaded.lat!), longitude: Double(locationLoaded.long!))
                    
                    tmpFullLocations.append(tmpLocation)
                    
                    locationCoords.append(CLLocationCoordinate2D(latitude: Double(locationLoaded.lat!), longitude: Double(locationLoaded.long!)))
                    
                }
                
                self.myLocations = locationCoords
                self.myLocationsFull = tmpFullLocations
                
            }
            
            
        }
        catch
        {
            //
            print ("Error fetching locations Data")
        }
        
        
        
    }
    
    //
    
    func loadCloudKitLocations()
    {
        
        let defaultContainer = CKContainer.defaultContainer()
        let privateDB = defaultContainer.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "PathData", predicate: predicate)
        
        privateDB.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            
            if (error != nil)
            {
                print(error)
                
            }
            else
            {
                
                // Success.
                
                
                var locationCoords : [CLLocationCoordinate2D] = []
                
                
//                for locationLoaded in results!
//                {
//                    print(locationLoaded.valueForKey("locationList")!)
                    
                    self.myLocationsFull = results![0].valueForKey("locationList")! as! [CLLocation]
                    
                    for myLocationFull in self.myLocationsFull
                    {
                        locationCoords.append(CLLocationCoordinate2D(latitude: Double(myLocationFull.coordinate.latitude), longitude: Double(myLocationFull.coordinate.longitude)))
                        
                    }
                    
//                }
                

                self.myLocations = locationCoords
                
                self.plotLocations()
                
            }
            
            
        }
        
    }
    
    
    
    ///
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error in location manager \(error)")
        
    }

    @IBAction func showAddPinVC(sender: AnyObject) {
        
        self.pinImage.hidden = false
        
        if (locationManager.location != nil)
        {
            centerMapOnLocation(locationManager.location!)
        }
        
        let destinationVC = self.childViewControllers[0] as? AddSavedPinViewController
        destinationVC?.delegate = self

        addPinContainer.alpha = 0.0
        addPinContainer.frame.origin.y = -300
        addPinContainer.hidden = false
        
        btnAddPin.enabled = false
       
        UIView.animateWithDuration(0.5, delay: 0.3, options: [.CurveEaseInOut], animations: {
            self.addPinContainer.frame.origin.y = 130
            self.addPinContainer.alpha = 1.0
        }, completion: nil)
        
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseIn, animations: {
            
            var iconView1Frame = self.iconView1.frame
            iconView1Frame.origin.x = -99
            self.iconView1.frame = iconView1Frame
            
            }, completion: { finished in
                print("Icon moved out")
        })
        
    }
    
    func hideAddPinVC()
    {
        
        self.pinImage.hidden = true
        
        UIView.animateWithDuration(0.5, delay: 0.1, options: [.CurveEaseInOut], animations: {
            self.addPinContainer.frame.origin.y = -300
            self.addPinContainer.alpha = 0.0
            },
            completion: {
                (finished: Bool) in
                if (finished)
                {
                    self.addPinContainer.hidden = true
                    self.btnAddPin.enabled = true

                }
            }
            

         )
        
        UIView.animateWithDuration(0.4, delay: 0.5, options: .CurveEaseOut, animations: {
            
            var iconView1Frame = self.iconView1.frame
            iconView1Frame.origin.x = 9
            self.iconView1.frame = iconView1Frame
            
            }, completion: { finished in
                print("Icon moved back in again")
        })
        
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "mySavedPin"
        
//        let R = Float(self.lineColor[0] as! NSNumber)
//        let G = Float(self.lineColor[1] as! NSNumber)
//        let B = Float(self.lineColor[2] as! NSNumber)
        
        
        if annotation is SavedPin {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) // as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.image = UIImage(named: "AddPin")!
                let fx = annotationView!.frame.origin.x
                let fy = annotationView!.frame.origin.y
                annotationView!.frame = CGRect(x: fx, y: fy, width: 54, height: 54)

//                annotationView!.pinTintColor = UIColor(colorLiteralRed: R/255, green: G/255, blue: B/255, alpha: 1.0)
//                annotationView!.animatesDrop = true
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
        
        let R = Float(self.lineColor[0] as! NSNumber)
        let G = Float(self.lineColor[1] as! NSNumber)
        let B = Float(self.lineColor[2] as! NSNumber)
        
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            
            
            pr.strokeColor = UIColor(colorLiteralRed: R/255, green: G/255, blue: B/255, alpha: 0.7)
      
            
            pr.lineWidth = 7 // 20 * self.currentZoomScale!
            pr.alpha = 0.7
            return pr
        } else if (overlay is MKCircle) {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor(colorLiteralRed: R/255, green: G/255, blue: B/255, alpha: 0.7)
            circleRenderer.fillColor = UIColor(colorLiteralRed: R/255, green: G/255, blue: B/255, alpha: 0.4) //UIColor.yellowColor().colorWithAlphaComponent(0.4)
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
    
    
    func prepopulateBridgeAlertPins()
    {
        
        let bridgeArray = [
            [1,"South Melbourne,Albert Road",3.0,-37.842008,144.95957],
            [2,"South Melbourne,York Street",3.0,-37.832099,144.954938],
            [3,"South Melbourne,82 Montague",3.0,-37.829773,144.949226],
            [4,"South Melbourne,444 City Road",3.0,-37.830711,144.95448],
            [5,"Melbourne,33 Spencer Street",3.0,-37.821324,144.955207],
            [6,"Melbourne,574 Flinders Street",3.0,-37.821185,144.954657],
            [7,"Melbourne,Kings Way SEA LIFE",3.0,-37.820907,144.957817],
            [8,"Melbourne,William Street",3.0,-37.819786,144.960162],
            [9,"Melbourne,Queensbridge",3.0,-37.819626,144.961459],
            [10,"East Melbourne,Batman Ave",3.0,-37.818402,144.975469],
            [11,"East Melbourne,Jolimont Road",3.0,-37.816024,144.979063],
            [12,"Cremorne,Cremorne Rail Bridge",3.0,-37.834018,144.993124],
            [13,"Cremorne,Balmain St",3.0,-37.83018,144.993904],
            [14,"Cremorne,Dunn Street",3.0,-37.82725,144.994009],
            [15,"Richmond,Swan Street",3.0,-37.825029,144.992199],
            [16,"Richmond,Punt Road South",3.0,-37.823483,144.989057],
            [17,"Richmond,Punt Road North",3.0,-37.823986,144.988822],
            [18,"Richmond,Egan Street",3.0,-37.813912,144.991893],
            [19,"Richmond,York Street",3.0,-37.813029,144.992064],
            [20,"Richmond,Garfield Street",3.0,-37.811749,144.992289],
            [21,"Richmond,Elizabeth Street",3.0,-37.811067,144.992395],
            [22,"Richmond,Victoria Street",3.0,-37.809727,144.992619],
            [23,"Abbotsford,Greenwood Street",3.0,-37.808314,144.992994],
            [24,"Abbotsford,Bloomburg Street",3.0,-37.807684,144.993213],
            [25,"Abbotsford,Langridge Street",3.0,-37.807267,144.993302],
            [26,"Abbotsford,Gipps Street",3.0,-37.80514,144.993632],
            [27,"Abbotsford,Vere Street",3.0,-37.802706,144.994096],
            [28,"Abbotsford,Yarra Street",3.0,-37.801977,144.994166],
            [29,"Abbotsford,Studley Street",3.0,-37.801335,144.994188],
            [30,"Abbotsford,Stafford Street",3.0,-37.800669,144.994205],
            [31,"Abbotsford,Johnson Street",3.0,-37.799974,144.994289],
            [32,"Clifton Hill,Noone Street",3.0,-37.793829,144.995309],
            [33,"Clifton Hill,Roseneath Street",3.0,-37.792505,144.995235],
            [34,"Clifton Hill,Queens Pde",3.0,-37.785124,144.995106],
            [35,"Clifton Hill,Urguhart Street",3.0,-37.784395,144.997037],
            [36,"Clifton Hill,Merri Pde",3.0,-37.779821,144.992193],
            [37,"Were Street,Middle Brighton",3.3,-37.916254, 144.995173]
        ]
        
        for bridgeItem in bridgeArray
        {
            
//            let id      = bridgeItem[0] as? String
            
            let identifier = NSUUID().UUIDString
            var note    = bridgeItem[1] as? String
            note = note! + " Final Warning"
            var note2   = note! + " First Warning"
            let height  = bridgeItem[2] as? Double
            let lat     = bridgeItem[3] as? Double
            let long    = bridgeItem[4] as? Double
            
            print("Adding pin \(note!) \(height!)")
            
            let coordinate = CLLocationCoordinate2DMake(lat!, long!)
            
            let savedPin = SavedPin(coordinate: coordinate, radius: 100.0, identifier: identifier, note: note!, eventType: .OnEntry)
            let savedPin2 = SavedPin(coordinate: coordinate, radius: 250.0, identifier: identifier, note: note2, eventType: .OnEntry)
            
            addSavedPin(savedPin)
            addSavedPin(savedPin2)
//
            // 2
            startMonitoringSavedPin(savedPin)
            startMonitoringSavedPin(savedPin2)
            
        }
        
//        saveAllPins()
        
        
        
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
    
        // NS defaults method has been superseded by Core Data Model -- see loadLocations
    
//        func loadAllLocations() {
//            myLocations = []
//            
//            if let savedLocations = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedLocationsKey) {
//                for savedLocation in savedLocations {
//                
////                    print("Got a location that was saved \(savedLocation)")
//                    
//                    if let savedLocation = NSKeyedUnarchiver.unarchiveObjectWithData(savedLocation as! NSData) as? NSDictionary {
//                        
//                        let lat         = savedLocation["lat"] as? Double
//                        let long        = savedLocation["long"] as? Double
//                        
//                        if (lat != nil && long != nil)
//                        {
//                        
//                            let locationItem : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
//                            
//                            myLocations.append(locationItem)
//                            
//                        }
//                    }
//                }
//            }
//        }
    
        func saveAllLocations() {
            let locations = NSMutableArray()
            
            for locationItem in self.myLocations {
                
                let locationItemAsObject : NSDictionary = [
                    "lat" : locationItem.latitude,
                    "long" : locationItem.longitude
                ]
                
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
        region.notifyOnEntry = true // (savedPin.eventType == .OnEntry)
        region.notifyOnExit = false // !region.notifyOnEntry
        return region
    }
    
    func startMonitoringSavedPin(savedPin: SavedPin) {
        // 1
        if !CLLocationManager .isMonitoringAvailableForClass(CLCircularRegion) {
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
    
    func loadFriends()
    {
        

        // Add a randomizer cache buster
        let url = NSURL(string: "http://seniorcreative.com.au/data/friends.json?rnd=" + NSUUID().UUIDString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            if (error == nil)
            {
                
                do
                {
                    
                    let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
//                    print("writing json friends \(jsonString)")
                    self.fileIO.write("jsonfriends.txt", withData: jsonString)
                    
                    
                }
                catch
                {
                    
                    
                    print("Error loading friends feed")
                    
                }
                
            }
            else
            {
                // there was an error with the data
            }
            
        }
        
        task.resume()
        
        
    }
    
    // see above the colon for selector means our function has one parameter
    func resetPaths()
    {
        print("Reset paths notification received")
        
        let alertView = UIAlertController(title: "Pathwayz Cleared", message: "Your pathwayz have now been reset", preferredStyle: UIAlertControllerStyle.Alert)
        
        //        alertView.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertView, animated: true, completion: nil)
        
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
            
        }
        
        self.myLocations = []
    }
    
    func setInitials()
    {

        
        var firstName = NSUserDefaults.standardUserDefaults().stringForKey("firstNameKey")
        var lastName = NSUserDefaults.standardUserDefaults().stringForKey("lastNameKey")
        var initials = ""
        if (firstName != nil && firstName?.characters.count >= 1)
        {
            let firstNameChar = firstName![firstName!.startIndex]
            initials = initials + String(firstNameChar)
            print("first name char not blank \(firstNameChar)")
        }
        else
        {
            firstName = "Enter"
            initials += "?"
        }
        
        if (lastName != nil && lastName?.characters.count >= 1)
        {
            let lastNameChar  = lastName![lastName!.startIndex]
            initials = initials + String(lastNameChar)
        }
        else
        {
            lastName = "name"
            initials += "?"
        }
    
        iconNameLabel.text = initials
    }
    
    
    @IBAction func syncAction(sender: AnyObject) {
        
        
        // 1. Create a UNIQUE record ID
        let timestampAsString = String(format: "%f", NSDate.timeIntervalSinceReferenceDate())
        let timestampParts = timestampAsString.componentsSeparatedByString(".")
        let uniqueId = timestampParts[0]
        
        // let todoId = CKRecordID(recordName: timestampParts[0])
        let locationSyncRecordID = CKRecordID(recordName: uniqueId)
        
        
        // 2. Create a CKRecord
        let locationSyncRecord = CKRecord(recordType: "PathData", recordID: locationSyncRecordID)
        
        
        // 3. Set value field on our record.
        //        let todoDesc = alertVC.textFields![0].text!
        locationSyncRecord.setObject(self.myLocationsFull, forKey: "locationList")
        locationSyncRecord.setObject("User1", forKey: "userID")
        
        var defaultContainer = CKContainer.defaultContainer()
        
        var privateDB = defaultContainer.privateCloudDatabase
        
        privateDB.saveRecord(locationSyncRecord, completionHandler: { (record, error) -> Void in
            
            // Cloud kit has returned here.
            if (error != nil)
            {
                
                print(error)
                
            }
            else
            {
                
                // Update UI?
                print("Successfully saved list of full locations.")
                
//                // Get around issue of table not updating from the process thread
//                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                    
//                    self.todos.append(record!)
//                    self.tableView.reloadData()
//                    
//                })
                
            }
            
        })
        
        
    }
    

}

