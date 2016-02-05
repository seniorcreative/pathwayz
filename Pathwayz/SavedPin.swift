//
//  SavedPin.swift
//  Pathwayz
//
//  Created by Steven Smith on 4/02/2016.
//  Copyright © 2016 Steven Smith. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

let kSavedPinLatitudeKey        = "latitude"
let kSavedPinLongitudeKey       = "longitude"
let kSavedPinRadiusKey          = "radius"
let kSavedPinIdentifierKey      = "identifier"
let kSavedPinNoteKey            = "note"
let kSavedPinEventTypeKey       = "eventType"
let kSavedPinTimeKey            = "pinTime"

enum EventType: Int {
    case OnEntry = 0
    case OnExit
}

class SavedPin: NSObject, NSCoding, MKAnnotation {
   
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var eventType: EventType
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType == .OnEntry ? "On Entry" : "On Exit"
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
        
        self.coordinate         = coordinate
        self.radius             = radius
        self.identifier         = identifier
        self.note               = note
        self.eventType          = eventType
        
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder) {
        
        let latitude            = decoder.decodeDoubleForKey(kSavedPinLatitudeKey)
        let longitude           = decoder.decodeDoubleForKey(kSavedPinLongitudeKey)
        coordinate              = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius                  = decoder.decodeDoubleForKey(kSavedPinRadiusKey)
        identifier              = decoder.decodeObjectForKey(kSavedPinIdentifierKey) as! String
        note                    = decoder.decodeObjectForKey(kSavedPinNoteKey) as! String
        eventType               = EventType(rawValue: decoder.decodeIntegerForKey(kSavedPinEventTypeKey))!
        
    }
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeDouble(coordinate.latitude, forKey: kSavedPinLatitudeKey)
        coder.encodeDouble(coordinate.longitude, forKey: kSavedPinLongitudeKey)
        coder.encodeDouble(radius, forKey: kSavedPinRadiusKey)
        coder.encodeObject(identifier, forKey: kSavedPinIdentifierKey)
        coder.encodeObject(note, forKey: kSavedPinNoteKey)
        coder.encodeInt(Int32(eventType.rawValue), forKey: kSavedPinEventTypeKey)
        
    }
}
