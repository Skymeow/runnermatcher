//
//  ChatListViewController.swift
//  iosapp
//
//  Created by Sky Xu on 8/16/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import UIKit
import FirebaseDatabase
class ChatListViewController: UIViewController {

    var chats = [Chat]()
    // to store ref to the DatabaseHandle and Refs, to clean up and stop observing data when view controller is dismissed
    var userChatsHandle: DatabaseHandle = 0
    var userChatsRef: DatabaseReference?
    // subviews
    @IBOutlet weak var tableView: UITableView!
    
    // VC Lifecycle
    // caz it's root view controller of the UINavigationController
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 71
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        // user service to observe current user's chats
        userChatsHandle = UserService.observeChats { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats
            // once completion handler execute, update UI on main thread
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
    }
    
    deinit {
        userChatsRef?.removeObserver(withHandle: userChatsHandle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
//configure table view
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        
        let chat = chats[indexPath.row]
        cell.titleLabel.text = chat.title
        cell.lastMessageLabel.text = chat.lastMessage
        
        return cell
    }
}
