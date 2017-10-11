//
//  Geolocation.swift
//  TrackMe
//
//  Created by KhanhND on 10/10/17.
//  Copyright © 2017 KhanhND. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import MapKit
import CoreLocation

class Geolocation: NSObject {
    var latitude: Double?
    var longitude: Double?
    var radius: String?
    var location: String?
    
    init(json: JSON) {
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
        radius = json["radius"].stringValue
        location = json["location"].stringValue
    }
}


