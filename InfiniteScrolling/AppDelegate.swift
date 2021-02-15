//
//  AppDelegate.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 11.02.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var navController = UINavigationController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13, *) {
            // do only pure app launch stuff, not interface stuff
        } else {
            self.window = UIWindow()
            window?.overrideUserInterfaceStyle = .light
            let vm = FlickrViewModel()
            let vc: FeedViewController
            if UIDevice.current.orientation.isLandscape {
                vc = FeedViewController(maxCountOfItemsInSection: MaxCountOfItemsInSection.horizontal.rawValue, viewmodel: vm)
            } else {
                vc = FeedViewController(maxCountOfItemsInSection: MaxCountOfItemsInSection.vertical.rawValue, viewmodel: vm)
            }
            navController.pushViewController(vc, animated: true)
            self.window?.rootViewController = navController
            self.window?.makeKeyAndVisible()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

