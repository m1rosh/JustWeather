//
//  WeatherStruct.swift
//  JustWeather
//
//  Created by Сергей Мирошниченко on 23.03.2024.
//

struct WeatherData: Codable {
    let current: CurrentWeatherData
    let forecast: ForecastWeatherData
}

struct CurrentWeatherData: Codable, Hashable {
    let temp_c: Double
    let wind_kph: Double
    let wind_dir: String
    let pressure_mb: Double
    let precip_mm: Double
    let humidity: Int
    let cloud: Int
    let feelslike_c: Double
    let uv: Double
    let gust_kph: Double
}

struct Condition: Codable, Hashable {
    let text: String
    let icon: String
}

struct OneDay: Codable, Hashable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: Condition
}

struct OneForecast: Codable, Hashable {
    let date: String
    let day: OneDay
}

struct ForecastWeatherData: Codable, Hashable {
    let forecastday: [OneForecast]
}





