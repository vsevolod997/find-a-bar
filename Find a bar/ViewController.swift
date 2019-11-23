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
        
        BarSearcherService.getMyBar(userPosition: location) { (error, resBars, length) in
            if let err = error{
                self.errorController(erro: err.rawValue)
            }else {
                guard let bars = resBars, let lng = length else { return }
                print(bars, Int(lng))
            }
        }
        
    }
    
    private func errorController(erro: String){
        let alert = UIAlertController(title: "Внимание", message: erro, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}


extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate:CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(coordinate.latitude) \(coordinate.longitude)")
    }
}

