//
//  SceneDelegate.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 11.02.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    lazy var navController = UINavigationController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            window?.overrideUserInterfaceStyle = .light
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let vm = FlickrViewModel(context: appDelegate.persistentContainer.viewContext)
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
    }
}

