//
//  AppDelegate.swift
//  JustWeather
//
//  Created by Сергей Мирошниченко on 23.03.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let factory = AppFactory()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.backgroundColor = .white
        
        var rootViewController: UIViewController?
        rootViewController = factory.buildTabBar()
        
        guard let rootViewController else { return false }
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        let root = navigationController
        
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        window?.backgroundColor = .white
        
        return true
    }
}
