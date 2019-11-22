//
//  ViewController.swift
//  Find a bar
//
//  Created by Всеволод Андрющенко on 21.11.2019.
//  Copyright © 2019 Всеволод Андрющенко. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import MapKit

class ViewController: UIViewController {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar()

        self.view.backgroundColor = .red
    }

    private func searchBar(){
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        guard let location =  locationManager.location?.coordinate else { return }
        
        BarSearcherService.getMyBar(userPosition: location) { (error, resBars) in
            if let err = error{
                
            }else {
                guard let bars = resBars else { return  }
                
            }
        }
        
    }
    
    func save(){
       if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        guard let location =  locationManager.location?.coordinate else { return }
        
        let stringGoogleQuery  = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.latitude),\(location.longitude)&radius=1500&type=bar&fields=formatted_address,name,rating,opening_hours,geometry&key=AIzaSyBr9HIxx4wEfhUs5VTidBNfOMCELlHBALA"
        guard let sstringGoogle =  stringGoogleQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        guard let urlGoogleQuery = URL(string: sstringGoogle) else {return}
        var urlReqest = URLRequest(url: urlGoogleQuery)
        urlReqest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlReqest) { (data, response, error) in
            if error == nil{
                let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                print(json)
                if let dict = json as? Dictionary<String, AnyObject>{
                    if let result = dict["results"] as? [Dictionary<String,AnyObject>]{
                        for place in result{
                            print(place["name"])
                            if let location = place["geometry"] as? Dictionary<String, AnyObject>{
                                print(location["location"])
                            }
                            print(place["vicinity"])
                            print(place["rating"])
                            print(place["place_id"])
                            print("------------------- ")
                        }
                    }
                }
            } else {
                print(error)
            }
        }
        task.resume()
    }
}


extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate:CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(coordinate.latitude) \(coordinate.longitude)")
    }
}

