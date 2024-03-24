//
//  AppFactory.swift
//  JustWeather
//
//  Created by Сергей Мирошниченко on 23.03.2024.
//

import UIKit
import CoreLocation

final class AppFactory {
    
    func buildTabBar() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            buildSearch(),
            buildCurrentWeather()
        ]
        
        tabBarController.selectedIndex = 1
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.unselectedItemTintColor = .gray
        
        return tabBarController
    }
    
    func buildCurrentWeather() -> UINavigationController {
        let currentWeather = WeatherViewController(locationManager: CLLocationManager(), saveCache: true)
        let weatherItem = UITabBarItem(title: "Текущая погода", image: UIImage(systemName: "location"), selectedImage: nil)
        currentWeather.tabBarItem = weatherItem
        let profileNavigationController = UINavigationController(rootViewController: currentWeather)
        
        return profileNavigationController
    }
    
    func buildSearch() -> UIViewController {
        let search = SearchViewController()
        let searchItem = UITabBarItem(title: "Поиск", image: UIImage(systemName: "magnifyingglass"), selectedImage: nil)
        search.tabBarItem = searchItem
        let searchNavigationController = UINavigationController(rootViewController: search)
        
        return searchNavigationController
    }
}
