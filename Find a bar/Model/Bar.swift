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
    
    init(id: String, name: String, latitude:Double, longitude:Double, adress: String) {
        self.id = id
        self.name = name
        self.adress = adress
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init?(json: [String: Any]) {
        
        guard
            let id = json["place_id"] as? String,
            let name  = json["name"] as? String,
            let location = json["geometry"] as? [String: Any],
            let coordinate  = location["location"] as? [String: Double],
            let lat = coordinate["lat"],
            let lng = coordinate["lng"],
            let adr = json["vicinity"] as? String
            else {
                return nil
            }
        
        self.adress = adr
        self.id = id
        self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.name = name
    }
    
    static func getArray(from jsonArray: Any) -> [Bar]? {
           
           guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
           var bars: [Bar] = []
           
           for jsonObject in jsonArray {
               if let task = Bar(json: jsonObject) {
                   bars.append(task)
               }
           }
           return bars
       }
}
