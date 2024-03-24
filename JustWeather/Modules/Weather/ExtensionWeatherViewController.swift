//
//  ExtensionWeatherViewController.swift
//  JustWeather
//
//  Created by Сергей Мирошниченко on 23.03.2024.
//

import UIKit
import CoreLocation

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData?.forecast.forecastday.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath)
        let mainCell = cell as? ForecastTableViewCell
        if let oneforecast = weatherData?.forecast.forecastday[indexPath.row] {
            mainCell?.configure(with: oneforecast)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            showAlert(alertTitle: "Нет доступа к геопозоции", alertMessage: "Разрешите приложению доступ к геопозиции в настройках")
            activityIndicator.stopAnimating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if let previousLocation = self.location {
                if abs(location.coordinate.latitude - previousLocation.coordinate.latitude) < 0.1 && abs(location.coordinate.longitude - previousLocation.coordinate.longitude) < 0.1 && !isRetrying {
                    return
                }
            }

            isRetrying = false
            self.location = location
            
            manageWithWeatherData(location: location)
            forecastTableView.reloadData()
        }
    }
}
extension WeatherViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        
        scrollView.addSubview(mainContentView)
        mainContentView.addSubview(oldInfoShowedLabel)
        
        mainContentView.addSubview(cloudsTitleLabel)
        mainContentView.addSubview(cloudsInfoLabel)
        
        mainContentView.addSubview(windTitleLabel)
        mainContentView.addSubview(windInfoLabel)
        
        mainContentView.addSubview(mainTitleLabel)
        mainContentView.addSubview(mainInfoLabel)
        
        mainContentView.addSubview(forecstTitleLabel)
        mainContentView.addSubview(forecastTableView)
        
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            mainContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            oldInfoShowedLabel.topAnchor.constraint(equalTo: mainContentView.topAnchor),
            oldInfoShowedLabel.centerXAnchor.constraint(equalTo: mainContentView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cloudsTitleLabel.topAnchor.constraint(equalTo: oldInfoShowedLabel.bottomAnchor, constant: 20),
            cloudsTitleLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            cloudsInfoLabel.centerYAnchor.constraint(equalTo: cloudsTitleLabel.centerYAnchor),
            cloudsInfoLabel.leadingAnchor.constraint(equalTo: cloudsTitleLabel.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: cloudsInfoLabel.bottomAnchor, constant: 30),
            mainTitleLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            mainInfoLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 15),
            mainInfoLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            windTitleLabel.topAnchor.constraint(equalTo: mainInfoLabel.bottomAnchor, constant: 30),
            windTitleLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            windInfoLabel.topAnchor.constraint(equalTo: windTitleLabel.bottomAnchor, constant: 15),
            windInfoLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            forecstTitleLabel.topAnchor.constraint(equalTo: windInfoLabel.bottomAnchor, constant: 50),
            forecstTitleLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            forecastTableView.topAnchor.constraint(equalTo: forecstTitleLabel.bottomAnchor),
            forecastTableView.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 5),
            forecastTableView.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: -5),
            forecastTableView.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: -20),
            forecastTableView.heightAnchor.constraint(equalToConstant: 500)
        ])
        
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        forecastTableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: "ForecastTableViewCell")
    }
}


