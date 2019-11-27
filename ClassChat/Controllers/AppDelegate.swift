//
//  AppDelegate.swift
//  ClassChatTest
//
//  Created by Yazan Arafeh on 11/20/19.
//  Copyright © 2019 Arafeh. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let storyboard = UIStoryboard(name: "Main", bundle: nil)
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    if Auth.auth().currentUser != nil {
      let viewController = storyboard.instantiateViewController(withIdentifier: "ChannelsNavigationController")
      self.window?.rootViewController = viewController
      self.window?.makeKeyAndVisible()
    } else {
      let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
      self.window?.rootViewController = viewController
      self.window?.makeKeyAndVisible()
    }
    return true
  }
}
