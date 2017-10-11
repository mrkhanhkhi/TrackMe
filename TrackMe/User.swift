//
//  User.swift
//  TrackMe
//
//  Created by KhanhND on 10/10/17.
//  Copyright © 2017 KhanhND. All rights reserved.
//

import SwiftyJSON
import Foundation

class User: NSObject {
    
    var name: String = ""
    var phoneNumber: String = ""
    
    convenience init(json: JSON) {
        self.init()
        name = json["name"].stringValue
        phoneNumber = json["phoneNumber"].stringValue
    }
}
