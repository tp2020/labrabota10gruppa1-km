//
//  WeatherGetter.swift
//  Lab9Task2.2
//
//  Created by Alex on 13.05.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation


protocol WeatherGetterDelegate {
  func didGetWeather(weather: Weather)
  func didNotGetWeather(error: NSError)
}

class WeatherGetter {
  
  private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
  private let openWeatherMapAPIKey = "558c5559d48cdb29121ec79f74c4d93d"
 
  private var delegate: WeatherGetterDelegate
  
  
  // MARK: -
  
  init(delegate: WeatherGetterDelegate) {
    self.delegate = delegate
  }
  
  func getWeatherByCity(city: String) {
    let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?&q=\(city)&APPID=\(openWeatherMapAPIKey)")!
    getWeather(weatherRequestURL: weatherRequestURL)
  }
    
    func getWeatherByCoordinates(latitude: Double, longitude: Double) {
      let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)")!
        getWeather(weatherRequestURL: weatherRequestURL as URL)
    }
  
 func getWeather(weatherRequestURL: URL) {
    
    // This is a pretty simple networking task, so the shared session will do.
    let session = URLSession.shared
    
    // The data task retrieves the data.
    let dataTask = session.dataTask(with:weatherRequestURL) {
      (data, response, error) in
      if let networkError = error {
        // Case 1: Error
        // An error occurred while trying to get data from the server.
        self.delegate.didNotGetWeather(error: networkError as NSError)
      }
      else {
        // Case 2: Success
        // We got data from the server!
        do {
          // Try to convert that data into a Swift dictionary
          let weatherData = try JSONSerialization.jsonObject(
            with: data!,
            options: .mutableContainers) as! [String: AnyObject]

          // If we made it to this point, we've successfully converted the
          // JSON-formatted weather data into a Swift dictionary.
          // Let's now used that dictionary to initialize a Weather struct.
          let weather = Weather(weatherData: weatherData)
          
          // Now that we have the Weather struct, let's notify the view controller,
          // which will use it to display the weather to the user.
            self.delegate.didGetWeather(weather:weather)
        }
        catch let jsonError as NSError {
          // An error occurred while trying to convert the data into a Swift dictionary.
            self.delegate.didNotGetWeather(error: jsonError)
        }
      }
    }
    
    // The data task is set up...launch it!
    dataTask.resume()
  }
  
}
