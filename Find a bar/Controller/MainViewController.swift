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
        
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(handlePressGestureGo(_:)))
        barNameLabel.addGestureRecognizer(recognizer)// добавление жеста нажатия
        
        let recognizer2 = UITapGestureRecognizer()
        recognizer2.addTarget(self, action: #selector(handlePressGestureUpdate(_:)))
        lengthLabel.addGestureRecognizer(recognizer2)// добавление жеста нажатия
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startView()
    }
    
    private func startView(){
        if Connection.isConnectedToNetwork(){
            searchBar()
        } else {
            searchIndicator.startAnimating()
            barNameLabel.text = "Проверте подключение к Интернету"
            adresBarLabel.text = "Возможно, Ваше устройство находиться в авиa - режиме."
            lengthLabel.text = "Повторить"
            lengthLabel.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - поиск ближайшего бара
    private func searchBar(){
        
        searchIndicator.startAnimating()
        barNameLabel.text = "Ожидайте"
        adresBarLabel.text = "поиск ближайшего бара"
        lengthLabel.text = ""
        lengthLabel.isUserInteractionEnabled = false
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        
        if let location = locationManager.location?.coordinate {
            
            BarSearcherService.getMyBar(userPosition: location) { (error, resBars, length) in
                if let err = error{
                    self.errorController(erro: err.rawValue)
                }else {
                    guard let bar = resBars, let lng = length else { return }
                    DispatchQueue.main.async {
                        self.myBar = bar
                        
                        let impact = UIImpactFeedbackGenerator(style: .heavy) // добавил обратную связь
                        impact.impactOccurred()
                        
                        self.barNameLabel.isUserInteractionEnabled = true
                        self.searchIndicator.stopAnimating()
                        self.lengthLabel.text = "До бара \(String(Int(lng))) м."
                        self.barNameLabel.text = bar.name
                        self.adresBarLabel.text =  bar.adress
                    }
                }
            }
        } else {
            errorController(erro: "Не удалось определить текущее местоположение")
        }
    }
    
    // MARK: - обработка возможных ошибок при работе
    private func errorController(erro: String){
        let alert = UIAlertController(title: "Внимание", message: erro, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    //MARK: - обработка нажатия на название бара
    @objc func handlePressGestureGo(_ gestureRecognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {
            self.barNameLabel.transform = .init(scaleX: 1.2, y: 1.2)
        }) { (anim) in
            let impact = UIImpactFeedbackGenerator(style: .heavy) // добавил обратную связь
            impact.impactOccurred()
            
            self.barNameLabel.transform = .init(scaleX: 1, y: 1)
            if let bar = self.myBar{
                if let urlDestination = URL.init(string: "https://www.google.com/maps/search/?api=1&query=\(bar.location.latitude),\(bar.location.longitude)&query_place_id=\(bar.id)")
                {
                UIApplication.shared.open(urlDestination, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    //MARK: - обработка нажатия при обновлении данных
    @objc func handlePressGestureUpdate(_ gestureRecognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {
            self.lengthLabel.transform = .init(scaleX: 1.2, y: 1.2)
        }) { (anim) in
            self.lengthLabel.transform = .init(scaleX: 1, y: 1)
            self.startView()
        }
    }
}

extension MainViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate:CLLocationCoordinate2D = manager.location?.coordinate {
            if let bar = myBar{
                let distance = BarSearcherService.distanceBetweenPoint(point1: coordinate, point2: bar.location)
                self.lengthLabel.text = "До бара \(String(Int(distance))) м."
                
                bearingOfBar = TranslateCoordinate.getBearingBetweenTwoPoints(bar.location, coordinate)
            }
        } else {
            errorController(erro: "Не удалось определить текущее местоположение")
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

