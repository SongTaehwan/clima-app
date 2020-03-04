//
//  WeatherData.swift
//  Clima
//
//  Created by 송태환 on 2020/03/04.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeatehr(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=e72ca729af228beabd5d20e3b7749713&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(urlString)
    }
    
    func fetchWeather(latitude lat: CLLocationDegrees, longitude lon: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(lat)&lon=\(lon)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        if let url = URL(string: urlString) { // to querystring
            print(url)
            let session = URLSession(configuration: .default) // create session and config
            let sessnioDataTask = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }

                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeatehr(self, weather: weather)
                    }
                }
            }
            
            sessnioDataTask.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> WeatherModel? {
        // JSON parser
        let decoder = JSONDecoder()
        do {
            // JSON format에 맞는 데이터 모델이 필요
            let weather = try decoder.decode(WeatherData.self, from: data)
            let temp = weather.main.temp
            let city = weather.name
            let id = weather.weather[0].id
            // 파싱한 데이터에서 필요한 데이터만 꺼내 WeatherModel 인스턴스에 담음
            let weatherModel = WeatherModel(cityName: city, conditionId: id, temperature: temp)
            return weatherModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
