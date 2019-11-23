//
//  ViewController.swift
//  Find a bar
//
//  Created by Всеволод Андрющенко on 21.11.2019.
//  Copyright © 2019 Всеволод Андрющенко. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
//import GoogleMaps
//import GooglePlaces
import MapKit

class MainViewController: UIViewController {

    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    @IBOutlet weak var compasView: UIImageView!
    @IBOutlet weak var barNameLabel: UILabel!
    let locationManager = CLLocationManager()
    @IBOutlet weak var adresBarLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    //let compasView = CompasView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar()
    }

    
    private func searchBar(){
        
        searchIndicator.startAnimating()
        barNameLabel.text = "Ожидайте"
        adresBarLabel.text = "поиск ближайшего бара"
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        
        guard let location =  locationManager.location?.coordinate else { return }
        
        //var buflocation = CLLocationCoordinate2D(latitude: 55.83, longitude: 37.29)
        BarSearcherService.getMyBar(userPosition: location) { (error, resBars, length) in
            if let err = error{
                print(Thread.current)
                self.errorController(erro: err.rawValue)
            }else {
                guard let bar = resBars, let lng = length else { return }
                DispatchQueue.main.async {
                    let impact = UIImpactFeedbackGenerator(style: .heavy) // добавил обратную связь
                    impact.impactOccurred()
                    
                    self.searchIndicator.stopAnimating()
                    self.lengthLabel.text = "До бара \(String(Int(lng))) м."
                    self.barNameLabel.text = bar.name
                    self.adresBarLabel.text =  bar.adress
                }
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


extension MainViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate:CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(coordinate.latitude) \(coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        //print(manager.heading)
    }
    
}

