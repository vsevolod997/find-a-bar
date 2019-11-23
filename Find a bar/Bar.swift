//
//  Bar.swift
//  Find a bar
//
//  Created by Всеволод Андрющенко on 22.11.2019.
//  Copyright © 2019 Всеволод Андрющенко. All rights reserved.
//

import Foundation
import CoreLocation

struct Bar{
    
    var id: String
    var name: String
    var location: CLLocationCoordinate2D
    var adress: String
    //ar reit: Double
    
    init(id: String, name: String, latitude:Double, longitude:Double, adress: String) {
        self.id = id
        self.name = name
        self.adress = adress
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //self.reit = reit
    }
}
