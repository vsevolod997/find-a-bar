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
import MapKit

class MainViewController: UIViewController {

    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    @IBOutlet weak var compasView: UIImageView!
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var adresBarLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    private var myBar: Bar?
    private var bearingOfBar: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar()
    }
    
    // MARK: - поиск ближайшего бара
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
        
        guard let location = locationManager.location?.coordinate else { return }
        
        BarSearcherService.getMyBar(userPosition: location) { (error, resBars, length) in
            if let err = error{
                self.errorController(erro: err.rawValue)
            }else {
                guard let bar = resBars, let lng = length else { return }
                DispatchQueue.main.async {
                    self.myBar = bar
                    
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
    
    // MARK: - обработка возможных ошибок при работе
    private func errorController(erro: String){
        let alert = UIAlertController(title: "Внимание", message: erro, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension MainViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate:CLLocationCoordinate2D = manager.location?.coordinate {
            print("locations = \(coordinate.latitude) \(coordinate.longitude)")
            if let bar = myBar{
                let distance = BarSearcherService.distanceBetweenPoint(point1: coordinate, point2: bar.location)
                self.lengthLabel.text = "До бара \(String(Int(distance))) м."
                
                bearingOfBar = TranslateCoordinate.getBearingBetweenTwoPoints(bar.location, coordinate)
            }
        } else {
            errorController(erro: "не удалось  получить текущее местоположение")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        if let bOfBar = bearingOfBar {
            let north =  -1 * heading.magneticHeading * Double.pi/180
            let barDirrection = bOfBar * Double.pi/180 + north + 180
            compasView.transform = CGAffineTransform(rotationAngle: CGFloat(barDirrection))
        }
    }
    
}

