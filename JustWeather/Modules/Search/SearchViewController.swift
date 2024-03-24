//
//  SearchViewController.swift
//  JustWeather
//
//  Created by Сергей Мирошниченко on 23.03.2024.
//

import UIKit
import CoreLocation

final class SearchViewController: UIViewController, UISearchBarDelegate {
    private var cityName: String?
    private var countryName: String?
    private var location: CLLocation?
    
    private var citiesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private var searchLocationImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "location.magnifyingglass"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .lightGray
        
        return imageView
    }()
    
    private var searchLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "Здесь отобразится результат..."
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Поиск"
        self.navigationItem.searchController = UISearchController(searchResultsController: nil)
        let searchBar = self.navigationItem.searchController?.searchBar
        
        searchBar?.delegate = self
        searchBar?.placeholder = "Город или населенный пункт"
        searchBar?.setValue("Отмена", forKey: "cancelButtonText")
        
        view.addSubview(citiesTableView)
        view.addSubview(searchLocationLabel)
        view.addSubview(searchLocationImageView)
        
        
        NSLayoutConstraint.activate([
            searchLocationImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchLocationImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            searchLocationImageView.widthAnchor.constraint(equalToConstant: 50 * 1.09),
            searchLocationImageView.heightAnchor.constraint(equalToConstant: 50),
            
            searchLocationLabel.leadingAnchor.constraint(equalTo: searchLocationImageView.trailingAnchor, constant: 10),
            searchLocationLabel.centerYAnchor.constraint(equalTo: searchLocationImageView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            citiesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            citiesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citiesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            citiesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        citiesTableView.dataSource = self
        citiesTableView.delegate = self
        citiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    func getCoordinates(for cityName: String, completion: @escaping(CLLocation?, String?, String?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { (placemarks, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            
            if let location = placemark.location {
                geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "Ru")) { (placemarks, error) in
                    if error != nil {
                        return
                    }
                
                    if let placemark = placemarks?.first {
                        if let city = placemark.locality, let country = placemark.country {
                            completion(location, city, country)
                            }
                        }
                    }
            } else {
                completion(nil, nil, nil)
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getCoordinates(for: searchText) {coordinates, city, country in
            if let coordinates = coordinates, let city = city, let country = country {
                self.location = coordinates
                self.cityName = city
                self.countryName = country
                self.citiesTableView.reloadData()
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cityName != nil {
            searchLocationLabel.isHidden = true
            searchLocationImageView.isHidden = true
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var configuration = UIListContentConfiguration.subtitleCell()
        
        if let cityName, let countryName {
            configuration.text = "\(cityName), \(countryName)"
            configuration.secondaryText = "Нажмите, чтобы посмотреть погоду"
        }
        else {configuration.text = ""}
        
        cell.contentConfiguration = configuration

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        citiesTableView.deselectRow(at: indexPath, animated: true)
        
        let weatherVC = WeatherViewController(location: location)
        navigationController?.pushViewController(weatherVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
