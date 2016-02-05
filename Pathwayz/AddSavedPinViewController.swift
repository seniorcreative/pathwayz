//
//  AddSavedPin.swift
//  Pathwayz
//
//  Created by Steven Smith on 4/02/2016.
//  Copyright © 2016 Steven Smith. All rights reserved.
//

import Foundation
import UIKit
//import MapKit

protocol AddSavedPinsViewControllerDelegate {
    func addSavedPinViewController(controller: AddSavedPinViewController,
        radius: Double, identifier: String, note: String, eventType: EventType)
}

class AddSavedPinViewController: UIViewController {
    
//    @IBOutlet var addButton: UIBarButtonItem!
//    @IBOutlet var zoomButton: UIBarButtonItem!
    
//    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
//    @IBOutlet weak var radiusTextField: UITextField!
//    @IBOutlet weak var noteTextField: UITextField!
//    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: AddSavedPinsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.rightBarButtonItems = [addButton, zoomButton]
//        addButton.enabled = false
        
//        tableView.tableFooterView = UIView()
    }
    
//    @IBAction func textFieldEditingChanged(sender: UITextField) {
//        addButton.enabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
//    }
//    
//    @IBAction func onCancel(sender: AnyObject) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    @IBAction private func onAdd(sender: AnyObject) {
//        let coordinate = mapView.centerCoordinate
        let radius = 100.0 // (radiusTextField.text! as NSString).doubleValue
        let identifier = NSUUID().UUIDString
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Hour , NSCalendarUnit.Minute], fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        
        
        let note = String(hour) + " : " + String(minutes)
        
        let eventType = EventType.OnEntry // (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? EventType.OnEntry : EventType.OnExit
        delegate!.addSavedPinViewController(self, radius: radius, identifier: identifier, note: note, eventType: eventType)
    }
//    
//    @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
////        zoomToUserLocationInMapView(mapView)
//    }
    
}
