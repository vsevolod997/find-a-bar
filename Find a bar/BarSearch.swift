//
//  BarSearch.swift
//  Find a bar
//
//  Created by Всеволод Андрющенко on 23.11.2019.
//  Copyright © 2019 Всеволод Андрющенко. All rights reserved.
//

import Foundation
import CoreLocation

class BarSearch {
    
    private let operationQueue = OperationQueue()
    
    class func getMyBar(userPosition: CLLocationCoordinate2D, allBar: [Bar],  complition: @escaping (Bar, Double) -> Void){
        
        var minLength: Double = Double(INT_MAX)
        var myBar: Bar!
        for bar in allBar{
            let length = distanceBetweenPoint(point1: userPosition, point2: bar.location)
            if length < minLength{
                minLength = length
                myBar = bar
            }
        }
        complition(myBar, minLength)
    }
    
    class func getAllBar(userPosition: CLLocationCoordinate2D) -> [Bar]? {
        
            var allBar: [Bar] = []
            let radius = 1500
            let stringGoogleQuery  = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(userPosition.latitude),\(userPosition.longitude)&radius=\(radius)&type=bar&fields=formatted_address,name,rating,opening_hours,geometry&key=AIzaSyBr9HIxx4wEfhUs5VTidBNfOMCELlHBALA"
            guard let sstringGoogle =  stringGoogleQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            
            guard let urlGoogleQuery = URL(string: sstringGoogle) else { return nil }
            var urlReqest = URLRequest(url: urlGoogleQuery)
            urlReqest.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: urlReqest) { (data, response, error) in
                if error == nil{
                    let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    //print(Thread.current)
                    if let dict = json as? Dictionary<String, AnyObject> {
                        if let result = dict["results"] as? [Dictionary<String,AnyObject>]{
                            print(result.count)
                            //print(result)
                            for place in result{
                                print("++++++++++++")
                                print(place)
                                print(Thread.current)
                                guard let name = place["name"] else { return }
                                var latitude: Double = 0.0
                                var longitude: Double = 0.0
                                if let location = place["geometry"] as? Dictionary<String, AnyObject>{
                                    if let coordinate = location["location"] as? Dictionary<String, Double> {
                                        guard let lat = coordinate["lat"] else { return }
                                        guard let lng = coordinate["lng"] else { return }
                                        latitude = lat
                                        longitude = lng
                                    }
                                }
                                guard let vicinity = place["vicinity"] else { return }
                                //guard let rating = place["rating"] else { return }
                                guard let id = place["place_id"] else { return }
                                let newBar = Bar(id: id as! String, name: name as! String, latitude: latitude, longitude: longitude, adress: vicinity as! String)
                                print("________________")
                                print(Thread.current)
                                allBar.append(newBar)
                                print(newBar)
                            }
                        } else {
                            print("XYI")
                        }
                    }
                } else {
                    print("XYI")
                }
            }
            task.resume()
        return allBar
    }
    
    class func distanceBetweenPoint(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double{
           let p1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
           let p2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
           
           return p1.distance(from: p2)
       }
    
}
