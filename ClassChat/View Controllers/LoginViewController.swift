//
//  LoginViewController.swift
//  ClassChat
//
//  Created by CMPE137 on 11/18/19.
//  Copyright © 2019 CMPE137. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
  
  @IBOutlet var getStartedButton: UIButton!
  @IBOutlet var displayNameField: UITextField!
  
  var handle: AuthStateDidChangeListenerHandle?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    getStartedButton.layer.cornerRadius = 4
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    displayNameField.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    displayNameField.text = ""
  }
  
  // MARK: - Actions
  
  @IBAction func actionButtonPressed() {
    signIn()
  }
  
  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    self.view.endEditing(true)
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "signIn" {
      handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        // Handle authenticated state
        if let user = user {
          let destinationNavigationController = segue.destination as! UINavigationController
          let channelsViewController = destinationNavigationController.topViewController as! ChannelsViewController
          channelsViewController.currentUser = user
        }
      }
    }
  }
  
  // MARK: - Helpers
  
  private func signIn() {
    guard let name = displayNameField.text, !name.isEmpty else {
      showMissingNameAlert()
      return
    }
    
    displayNameField.resignFirstResponder()
    AppSettings.displayName = name
    Auth.auth().signInAnonymously(completion: nil)
  }
  
  private func showMissingNameAlert() {
    let ac = UIAlertController(title: "Display Name Required", message: "Please enter a display name.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
      DispatchQueue.main.async {
        self.displayNameField.becomeFirstResponder()
      }
    }))
    present(ac, animated: true, completion: nil)
  }
  
}
