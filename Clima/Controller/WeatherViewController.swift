//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        weatherManager.delegate = self
        searchField.delegate = self
    }

    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

// MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        // input editing 종료
        searchField.endEditing(true)
    }

    // 리턴키 누르면 실행
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        // true for default behaviour for return button; otherwise, false
        return true;
    }
    
    // endEditing 실행 시 실행
    // true 리턴 시 textFieldDidEndEditing 실행
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            // 키보드 사라짐
            return true
        }

        searchField.placeholder = "Type Something"
        // false 리턴시 키보드 사라지지 않음
        return false;
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // api
        if let city = searchField.text {
           weatherManager.fetchWeather(cityName: city)
        }
        
        searchField.text = ""
    }
}


// MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeatehr(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.conditionImageView.image = UIImage(systemName: weather.cityName)
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon  = location.coordinate.longitude
            
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
