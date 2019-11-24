//
//  TranslateCoordinate.swift
//  Find a bar
//
//  Created by Всеволод Андрющенко on 24.11.2019.
//  Copyright © 2019 Всеволод Андрющенко. All rights reserved.
//

import Foundation
import CoreLocation

class TranslateCoordinate {
    
    private static func degreesToRadians(_ degrees: Double) -> Double
    {
        return degrees * Double.pi / 180.0
    }
    
    private static func radiansToDegrees(_ radians: Double) -> Double
    {
        return radians * 180.0 / Double.pi
    }
    
    // MARK: - нахождение угла между точками
    class func getBearingBetweenTwoPoints(_ point1: CLLocationCoordinate2D, _ point2:CLLocationCoordinate2D) -> Double {
        
        let lat1 = degreesToRadians(point1.latitude)
        let lon1 = degreesToRadians(point1.longitude)
        
        let lat2 = degreesToRadians(point2.latitude);
        let lon2 = degreesToRadians(point2.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        var radiansBearing = atan2(y, x);
        if(radiansBearing < 0.0){
            
            radiansBearing += 2 * Double.pi;
        }
        
        return radiansToDegrees(radiansBearing)
    }
}
