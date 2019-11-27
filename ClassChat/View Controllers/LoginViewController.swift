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
  
  private func registerForKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
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
  
  // MARK: - Notifications
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
      return
    }
    guard let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
      return
    }
    guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
      return
    }
    
    let options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve << 16)
    bottomConstraint.constant = keyboardHeight + 20
    
    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    guard let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
      return
    }
    guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
      return
    }
    
    let options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve << 16)
    bottomConstraint.constant = 20
    
    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}
