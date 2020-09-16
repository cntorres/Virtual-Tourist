//
//  SceneDelegate.swift
//  Virtual Tourist
//
//  Created by Courtney Torres on 8/24/20.
//  Copyright © 2020 Courtney Torres. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "VirtualTourist")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        dataController.load()
        window = UIWindow(windowScene: windowScene) 
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = storyboard.instantiateViewController(identifier: "TravelLocationsViewController") as! TravelLocationsViewController
        let rootNC = UINavigationController(rootViewController: rootVC)
        rootNC.isNavigationBarHidden = true
        window?.rootViewController = rootNC
        window?.makeKeyAndVisible()
        rootVC.dataController = dataController
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        saveViewContext()
    }

    
    func saveViewContext(){
        try? dataController.viewContext.save()
    }

}

