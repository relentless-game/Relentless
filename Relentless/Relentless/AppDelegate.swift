//
//  AppDelegate.swift
//  Relentless
//
//  Created by Liu Zechu on 11/3/20.
//  Copyright © 2020 OurGroupNameIs. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private(set) var userId: String!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        // for anonymous authentication
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else {
                return
            }
            // TODO: figure out what to do with this
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            
            self.userId = uid
        }
        
        //TEST
        let userid = "myuserid"
        let gameController = GameControllerManager(userId: userid)
        gameController.createGame()
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be
        // called shortly after
        // application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
