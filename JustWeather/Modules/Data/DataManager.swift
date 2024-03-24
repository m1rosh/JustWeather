//
//  DataManager.swift
//  JustWeather
//
//  Created by Сергей Мирошниченко on 23.03.2024.
//

import UIKit
import CoreLocation

final class DataManager {
    private let apiKey = "c0ed305df64e455984a191711242403"
    
    func getWeatherByCoords(lon: Double, lat: Double, completion: @escaping (Result<Data, Error>) -> Void) {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=7&aqi=no"
    
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "No data received", code: 1, userInfo: nil)))
                }
                return
            }
            
            URLCache.shared.removeAllCachedResponses()
            completion(.success(data))
        }
        
        task.resume()
    }
    
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
