//
//  BarSearcherService.swift
//  Find a bar
//
//  Created by Всеволод Андрющенко on 22.11.2019.
//  Copyright © 2019 Всеволод Андрющенко. All rights reserved.
//

import Foundation
import CoreLocation

enum ErrorSearch: String {
    case notFound = "Нет баров в шаговой доступности =("
    case queryData = "Произошла ошибка в ходе выполнения запроса"
}

class BarSearcherService {
    
    //MARK: - Поиск ближайшего бара по координатам пользователя
    class func getMyBar(userPosition: CLLocationCoordinate2D, complition: @escaping (ErrorSearch?, Bar?) -> Void){
        //if let allBar = getAllBar(userPosition){
            
        //}else{
           // complition(.notFound, nil)
       // }
        getAllBar(userPosition: userPosition) { (error, res) in
            if let err = error{
                
            } else {
                guard let bars = res else { return }
                for bar in bars{
                    print(bar)
                }
            }
        }
        
    }
    
    
    
    private static func getAllBar(userPosition: CLLocationCoordinate2D, complition: @escaping(ErrorSearch?, [Bar]?)->Void) {
        var allBar: [Bar] = []
        
        let stringGoogleQuery  = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(userPosition.latitude),\(userPosition.longitude)&radius=1500&type=bar&fields=formatted_address,name,rating,opening_hours,geometry&key=AIzaSyBr9HIxx4wEfhUs5VTidBNfOMCELlHBALA"
        guard let sstringGoogle =  stringGoogleQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        guard let urlGoogleQuery = URL(string: sstringGoogle) else { return }
        var urlReqest = URLRequest(url: urlGoogleQuery)
        urlReqest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlReqest) { (data, response, error) in
            if error == nil{
                let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                //print(json)
                if let dict = json as? Dictionary<String, AnyObject>{
                    if let result = dict["results"] as? [Dictionary<String,AnyObject>]{
                        for place in result{
                            guard let name = place["name"] else { return }
                            var latitude: Double = 0.0
                            var longitude: Double = 0.0
                           // print(place["name"])
                            if let location = place["geometry"] as? Dictionary<String, AnyObject>{
                               // print(location["location"])
                                if let coordinate = location["location"] as? Dictionary<String, Double> {
                                 //   print(coordinate["lat"])
                                 //   print(coordinate["lng"])
                                    guard let lat = coordinate["lat"] else { return }
                                    guard let lng = coordinate["lng"] else { return }
                                    latitude = lat
                                    longitude = lng
                                }
                            }
                            guard let vicinity = place["vicinity"] else { return }
                            guard let rating = place["rating"] else { return }
                            guard let id = place["place_id"] else { return }
                           // print(place["vicinity"])
                           // print(place["rating"])
                           // print(place["place_id"])
                            let newBar = Bar(id:id as! String, name: name as! String, latitude: latitude, longitude: longitude, adress: vicinity as! String, reit: rating as! Double)
                            allBar.append(newBar)
                           // print(newBar)
                           // print("------------------- ")
                        }
                        complition(nil, allBar)
                    }
                }
            } else {
                complition(.queryData, nil )
            }
        }
        task.resume()
        
    }
    
}
