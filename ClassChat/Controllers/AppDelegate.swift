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
    FirebaseApp.configure() // Configure the Firebase app
    if Auth.auth().currentUser != nil { // If the user is signed in
      let viewController = storyboard.instantiateViewController(withIdentifier: "ChannelsNavigationController") // Create a ChannelsNavigationController
      self.window?.rootViewController = viewController  // Set it as the root view controller
      self.window?.makeKeyAndVisible()
    } else {  // If the user is not signed in
      let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")  // Create a LoginViewController
      self.window?.rootViewController = viewController  // Set it as the root view controller
      self.window?.makeKeyAndVisible()
    }
    return true
  }
}
