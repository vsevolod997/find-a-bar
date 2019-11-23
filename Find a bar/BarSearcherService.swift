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
    case errorData = "Получены некорректные данные"
}

class BarSearcherService {
    
    //MARK: - Поиск ближайшего бара по координатам пользователя
    class func getMyBar(userPosition: CLLocationCoordinate2D, complition: @escaping (ErrorSearch?, Bar?, Double?) -> Void){
        print(Thread.current)
        getAllBar(userPosition: userPosition) { (error, res) in
            if let err = error{
                complition(err, nil, nil)
            } else {
                var minLength: Double = Double(INT_MAX)
                var myBar: Bar!
                guard let bars = res else { return }
                if bars.count == 0 {
                    complition(.notFound, nil, nil)
                } else {
                    for bar in bars{
                        let length = distanceBetweenPoint(point1: userPosition, point2: bar.location)
                        if length < minLength{
                            minLength = length
                            myBar = bar
                             print(Thread.current)
                        }
                    }
                    complition(nil, myBar, minLength)
                }
            }
        }
        
    }
    
    //MARK: - Расстояние между точками
    class func distanceBetweenPoint(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double{
        let p1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
        let p2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
        
        return p1.distance(from: p2)
    }
    
    //MARK: - Все бары в радиусе 1500м (поиск по категории заведения)
    private static func getAllBar(userPosition: CLLocationCoordinate2D, complition: @escaping(ErrorSearch?, [Bar]?)->Void) {
        var allBar: [Bar] = []
        let radius = 1500
        let stringGoogleQuery  = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(userPosition.latitude),\(userPosition.longitude)&radius=\(radius)&type=bar&fields=formatted_address,name,rating,opening_hours,geometry&key=AIzaSyBr9HIxx4wEfhUs5VTidBNfOMCELlHBALA"
        guard let sstringGoogle =  stringGoogleQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        guard let urlGoogleQuery = URL(string: sstringGoogle) else { return }
        var urlReqest = URLRequest(url: urlGoogleQuery)
        urlReqest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlReqest) { (data, response, error) in
            if error == nil{
                let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                print(Thread.current)
                if let dict = json as? Dictionary<String, AnyObject>{
                    if let result = dict["results"] as? [Dictionary<String,AnyObject>]{
                        for place in result{
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
                            guard let id = place["place_id"] else { return }
                            let newBar = Bar(id: id as! String, name: name as! String, latitude: latitude, longitude: longitude, adress: vicinity as! String)
                            allBar.append(newBar)
                        }
                        complition(nil, allBar)
                    } else {
                        complition(.errorData, nil)
                    }
                }
            } else {
                complition(.queryData, nil)
            }
        }
        task.resume()
        
    }
    
}
