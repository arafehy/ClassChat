//
//  ChannelsViewController.swift
//  ClassChat
//
//  Created by CMPE137 on 11/18/19.
//  Copyright © 2019 CMPE137. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChannelsViewController: UITableViewController {
  
  @IBOutlet weak var displayNameLabel: UIBarButtonItem!
  
  private let channelCellIdentifier = "channelCell"
  private var currentChannelAlertController: UIAlertController?
  
  private let db = Firestore.firestore()
  
  private var channelReference: CollectionReference {
    return db.collection("channels")
  }
  
  private var channels = [Channel]()    // Array of available channels
  private var channelListener: ListenerRegistration?
  
  var currentUser: User? = Auth.auth().currentUser  // Set current user
  
  deinit {
    channelListener?.remove()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.prefersLargeTitles = true   // Set large titles
    displayNameLabel.title = AppSettings.displayName               // Show display name in toolbar
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)
    
    channelListener = channelReference.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.isNavigationBarHidden = false   // Show navigation bar
    navigationController?.isToolbarHidden = false         // Show toolbar
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isNavigationBarHidden = false   // Show navigation bar
    navigationController?.isToolbarHidden = true          // Hide toolbar to make room for MessageInputBar
  }
  
  // MARK: - Actions
  
  /**
   Function to sign out of Firebase and return to LoginViewController
   */
  @IBAction func signOut(_ sender: UIBarButtonItem) {
    let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
      do {
        try Auth.auth().signOut()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if self.navigationController == appDelegate.window?.rootViewController {  // ChannelsViewController is root view controller
          // Create instance of LoginViewController since it hasn't been created
          let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
          let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
          appDelegate.window?.rootViewController = viewController   // Make LoginViewController the root view controller
          appDelegate.window?.makeKeyAndVisible()
        }
        else {  // LoginViewController is root view controller
          self.dismiss(animated: true, completion: nil) // Dismiss ChannelsViewController
        }
      } catch {
        print("Error signing out: \(error.localizedDescription)")
      }
    }))
    present(ac, animated: true, completion: nil)    // Show alert
  }
  
  @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
    let ac = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    ac.addTextField { field in
      field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
      field.enablesReturnKeyAutomatically = true
      field.autocapitalizationType = .words
      field.clearButtonMode = .whileEditing
      field.placeholder = "Channel name"
      field.returnKeyType = .done
    }
    
    let createAction = UIAlertAction(title: "Create", style: .default, handler: { _ in
      self.createChannel()
    })
    createAction.isEnabled = false
    ac.addAction(createAction)
    ac.preferredAction = createAction
    
    present(ac, animated: true) {
      ac.textFields?.first?.becomeFirstResponder()
    }
    currentChannelAlertController = ac
  }
  
  @objc private func textFieldDidChange(_ field: UITextField) {
    guard let ac = currentChannelAlertController else {
      return
    }
    
    ac.preferredAction?.isEnabled = field.hasText
  }
  
  // MARK: - Helpers
  
  /**
   Function to create a channel
   */
  private func createChannel() {
    guard let ac = currentChannelAlertController else {
      return
    }
    
    guard let channelName = ac.textFields?.first?.text else {
      return
    }
    
    let channel = Channel(name: channelName)
    channelReference.addDocument(data: channel.representation) { error in
      if let e = error {
        print("Error saving channel: \(e.localizedDescription)")
      }
    }
  }
  
  /**
   Function to add a channel to the table view
   - Parameter channel: The channel to add to the table view
   */
  private func addChannelToTable(_ channel: Channel) {
    guard !channels.contains(channel) else {
      return
    }
    
    channels.append(channel)
    channels.sort()
    
    guard let index = channels.firstIndex(of: channel) else {
      return
    }
    tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }
  
  /**
   Function to update the index of a channel in the table view
   - Parameter channel: The channel to update
   */
  private func updateChannelInTable(_ channel: Channel) {
    guard let index = channels.firstIndex(of: channel) else {
      return
    }
    
    channels[index] = channel
    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }
  
  /**
   Function to remove a channel from the table
   - Parameter channel: The channel to remove
   */
  private func removeChannelFromTable(_ channel: Channel) {
    guard let index = channels.firstIndex(of: channel) else {
      return
    }
    
    channels.remove(at: index)
    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }
  
  /**
  Function to handle changes to the channels
   - Parameter change: The change to handle
  */
  private func handleDocumentChange(_ change: DocumentChange) {
    guard let channel = Channel(document: change.document) else {
      return
    }
    
    switch change.type {
    case .added:
      addChannelToTable(channel)
      
    case .modified:
      updateChannelInTable(channel)
      
    case .removed:
      removeChannelFromTable(channel)
    @unknown default:
      break
    }
  }
  
}

// MARK: - TableViewDelegate

extension ChannelsViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return channels.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath)
    
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = channels[indexPath.row].name
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let channel = channels[indexPath.row]
    let vc = ChatViewController(user: currentUser!, channel: channel)
    navigationController?.pushViewController(vc, animated: true)
  }
  
}
