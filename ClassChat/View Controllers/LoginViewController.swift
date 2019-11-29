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
    
    getStartedButton.layer.cornerRadius = 4   // Round Get Started button corners
    
    // Add tap recognizer to hide keyboard when tapping the view
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    displayNameField.becomeFirstResponder()   // Open keyboard and make display name text field active when Login view appears
  }
  
  override func viewWillAppear(_ animated: Bool) {
    displayNameField.text = ""    // Reset display name text field
  }
  
  // MARK: - Actions
  
  @IBAction func actionButtonPressed() {
    signIn()
  }
  
  /**
   Function to end editing on all text fields
   */
  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    self.view.endEditing(true)
    return true
  }
  
  /**
   Function to pass current user to ChannelsViewController
   - Parameter segue: The segue to call this function
   */
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
  
  /**
   Function for signing in anonymously with Firebase using the user given display name
   */
  private func signIn() {
    guard let name = displayNameField.text, !name.isEmpty else {  // If display name field is empty
      showMissingNameAlert()    // Show alert
      return
    }
    
    displayNameField.resignFirstResponder()   // Stop editing field and hide keyboard
    AppSettings.displayName = name            // Store display name in UserDefaults
    Auth.auth().signInAnonymously(completion: nil)    // Sign in anonymously
  }
  
  /**
   Function to show an alert if the display name field is empty when trying to sign in
   */
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
