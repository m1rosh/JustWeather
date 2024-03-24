//
//  WeatherViewController.swift
//  JustWeather
//
//  Created by Сергей Мирошниченко on 23.03.2024.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController  {
    
    var oldInfoShowedLabel: UILabel = {
        let label = UILabel()
        label.text = "Сохраненная информация о погоде"
        label.textColor = .red
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var mainContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    var forecstTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Прогноз на 7 дней:"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.isHidden = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()

    var cloudsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Облачность: "
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var cloudsInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var windTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ветер:"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var windInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var mainTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Основная информация: "
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var mainInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        
        return indicator
    }()

    var forecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    let dataManager = DataManager()
    
    var cachedInfoLoaded = false
    var isRetrying = false
    var saveCache = false
    var noInternet = false
    
    var weatherData: WeatherData?
    var location: CLLocation?
    var myLocationManager: CLLocationManager?
    
    init(locationManager: CLLocationManager? = nil, location: CLLocation? = nil, saveCache: Bool? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let locationManager, let saveCache {
            self.myLocationManager = locationManager
            self.saveCache = saveCache
        }
        if let location {
            self.location = location
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let myLocationManager {
            if myLocationManager.authorizationStatus.rawValue == 2 {
                showAlert(alertTitle: "Нет доступа к геопозоции", alertMessage: "Разрешите приложению использовать геопозицию в настройках")
            }
            if self.noInternet {
                if let location {
                    manageWithWeatherData(location: location)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Погода"
        setupUI()
        
        if let myLocationManager {
            if myLocationManager.authorizationStatus.rawValue == 2 {
                showAlert(alertTitle: "Нет доступа к геопозоции", alertMessage: "Разрешите приложению использовать геопозицию в настройках")
                
                activityIndicator.stopAnimating()
                if !loadCachedInfo() {print("No Cache")}
            }
        }

        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                if let locationManager = self.myLocationManager {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.startUpdatingLocation()
                }
            }
        }
        
        if let location {
            manageWithWeatherData(location: location)
        }
    }
    
    func showAlert(alertTitle: String, alertMessage: String) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func getNamedLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        var locationToSave: [String] = []
        
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "Ru")) { (placemarks, error) in
            if error != nil {
                return
            }
        
            if let placemark = placemarks?.first {
                if let city = placemark.locality, let country = placemark.country {
                    self.navigationItem.title = "\(city), \(country)"
                    locationToSave.append(city)
                    locationToSave.append(country)
                    if self.saveCache {
                        if let encodedData = try? PropertyListEncoder().encode(locationToSave){
                            UserDefaults.standard.set(encodedData, forKey: "cachedLocation")
                        }
                    }
                }
            }
        }
    }
    
    private func loadCachedInfo() -> Bool {
        if let savedWeather = UserDefaults.standard.data(forKey: "cachedWeatherData"),
           let loadedWeather = try? PropertyListDecoder().decode([WeatherData].self, from: savedWeather) {
            if loadedWeather.count != 0 {
                self.weatherData = loadedWeather[0]
                DispatchQueue.main.async {
                    self.showWeatherInfo()
                    if let savedLocation = UserDefaults.standard.data(forKey: "cachedLocation"),
                       let loadedLocation = try? PropertyListDecoder().decode([String].self, from: savedLocation) {
                        if loadedLocation.count == 2 {
                            self.navigationItem.title = "\(loadedLocation[0]), \(loadedLocation[1])"
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    self.showAlert(alertTitle: "Нет подключения к интернету", alertMessage: "Проверьте подключение")
                    self.oldInfoShowedLabel.isHidden = false
                }
            }
            return true
        }
        self.noInternet = true
        return false
    }
    
    private func showWeatherInfo() {
        if let weatherData {
            cloudsInfoLabel.text = String(weatherData.current.cloud) + " %"
            
            mainInfoLabel.text = """
            Температура: \(weatherData.current.temp_c) °C \n
            Ощущается как: \(weatherData.current.feelslike_c) °C \n
            Давление: \(weatherData.current.pressure_mb) мб \n
            Влажность: \(weatherData.current.humidity) % \n
            Осадки: \(weatherData.current.precip_mm) мм \n
            УФ-индекс: \(weatherData.current.uv)
            """
            
            windInfoLabel.text = """
            Скорость: \(weatherData.current.wind_kph) км/ч \n
            Направление: \(weatherData.current.wind_dir) \n
            Порывы: \(weatherData.current.gust_kph) км/ч
            """
            
            forecastTableView.reloadData()
            scrollView.isHidden = false
        }
    }
    
    func manageWithWeatherData(location: CLLocation) {
        dataManager.getWeatherByCoords(lon: location.coordinate.longitude, lat: location.coordinate.latitude){ result in
            switch result {
            case .success(let data):
                self.noInternet = false
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    self.weatherData = weatherData
                    if self.saveCache {
                        if let encodedData = try? PropertyListEncoder().encode([self.weatherData]){
                            UserDefaults.standard.set(encodedData, forKey: "cachedWeatherData")
                        }
                    }
                    DispatchQueue.main.async {
                        self.oldInfoShowedLabel.isHidden = true
                        self.showWeatherInfo()
                        self.getNamedLocation(location: location)
                        self.activityIndicator.stopAnimating()
                    }
                } catch {
                    print(error)
                }
            case .failure(_):
                if self.myLocationManager != nil{
                    self.noInternet = true
                    if !self.loadCachedInfo(){
                        self.cachedInfoLoaded = true
                    }
                }
                DispatchQueue.main.async {
                    self.showAlert(alertTitle: "Нет подключения к интернету", alertMessage: "Проверьте подключение")
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
}
