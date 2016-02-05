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
    
    func hideAddPinVC()
}

class AddSavedPinViewController: UIViewController {
    
//    @IBOutlet var addButton: UIBarButtonItem!
//    @IBOutlet var zoomButton: UIBarButtonItem!
    
//    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
//    @IBOutlet weak var radiusTextField: UITextField!
//    @IBOutlet weak var noteTextField: UITextField!
//    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: AddSavedPinsViewControllerDelegate!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var noteField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.rightBarButtonItems = [addButton, zoomButton]
//        addButton.enabled = false
        
//        tableView.tableFooterView = UIView()
        
        cancelButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        self.view.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        self.view.layer.cornerRadius = 10
        
        
        saveButton.backgroundColor = UIColor.yellowColor()
        saveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        saveButton.layer.cornerRadius = saveButton.layer.visibleRect.height/2
//        saveButton.enabled = false
        
    }
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        
        print("text entered")
        
//        saveButton.enabled = !noteField.text!.isEmpty && !noteField.text!.isEmpty
        
    }
//
    @IBAction func onCancel(sender: AnyObject) {
        
        noteField.resignFirstResponder() // Done with the keyboard
        delegate!.hideAddPinVC()
    }
    
    
    
    
    @IBAction private func onAdd(sender: AnyObject) {
//        let coordinate = mapView.centerCoordinate
        let radius = 100.0 // (radiusTextField.text! as NSString).doubleValue
        let identifier = NSUUID().UUIDString
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Month,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        var minutePrefix = ""
        if (Int(components.minute) < 10)
        {
            minutePrefix = "0"
        }
        let year = components.year
        let day = components.day
        let month = components.month
        
        
//        let pinTime = String(day) + "/" + String(month) + "/" + String(year) + " " + String(hour) + ":" + minutePrefix + String(minutes)
        
        let note = noteField.text!
        
        let eventType = EventType.OnEntry // (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? EventType.OnEntry : EventType.OnExit
        
    
        noteField.resignFirstResponder() // Done with the keyboard.
        noteField.text = "" // Clear the field for next time
        delegate!.addSavedPinViewController(self, radius: radius, identifier: identifier, note: note, eventType: eventType)
        
    }
//    
//    @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
////        zoomToUserLocationInMapView(mapView)
//    }
    
}
