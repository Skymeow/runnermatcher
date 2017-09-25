//
//  ChatViewController.swift
//  iosapp
//
//  Created by Sky Xu on 8/16/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import JSQMessagesViewController.JSQMessage
import FirebaseDatabase
class ChatViewController: JSQMessagesViewController {

    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    var chat: Chat!
    var messages = [Message]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleBlue()
        return bubbleImageFactory.outgoingMessagesBubbleImage(with: color)
    }()
    
    var incomingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleLightGray()
        return bubbleImageFactory.incomingMessagesBubbleImage(with: color)
    }()
    
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupJSQMessagesViewController()
        tryObservingMessages()
       
        let cutomizedView = UIView()
        self.view.addSubview(cutomizedView)
        cutomizedView.backgroundColor = .blue
        cutomizedView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        cutomizedView.bottomAnchor.constraint(equalTo: self.collectionView.topAnchor).isActive = true
        cutomizedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        cutomizedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.heightAnchor.constraint(equalTo: cutomizedView.heightAnchor, multiplier: 2).isActive = true
        self.collectionView.backgroundColor = .green
        cutomizedView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }
    func setupJSQMessagesViewController() {
        senderId = User.current.uid
        senderDisplayName = User.current.first_name
        title = chat.title
        // 2. remove attachment button, make sender msgs to appear on right
        inputToolbar.contentView.leftBarButtonItem = nil
        // 3. remove avatars, caz our app doesn't have profile pic
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    func tryObservingMessages() {
        // check if chat exists in database
        guard let chatKey = chat?.key else { return }
        
        messagesHandle = ChatService.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
            self?.messagesRef = ref
            
            if let message = message {
                self?.messages.append(message)
                self?.finishReceivingMessage()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - JSQMessagesCollectionViewDataSource
extension ChatViewController {
    // return the number of messages to display
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // don't display user profile pic
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // return an object that conforms to data protocol, let JSQ know what text to display and the sender uid for the message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessageValue
    }
    
    // return outgoing buble if sender UID matchees current user UID
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let sender = message.sender
        if sender.uid == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    // set text color of message bubble based on whether sender is current user
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = (message.sender.uid == senderId) ? .white : .black
        return cell
    }
}

// MARK: - Send Message

extension ChatViewController {
    func sendMessage(_ message: Message) {
        // check if chat exist,if not, create a chat
        if chat?.key == nil {
            // need a msg to create a new chat
            ChatService.create(from: message, with: chat, completion: { [weak self] chat in
                guard let chat = chat else { return }
                
                self?.chat = chat
                
                // call tryObserve if creating chat succed
                self?.tryObservingMessages()
            })
        } else {
            // if chat already exists, update new msg to database
            ChatService.sendMessage(message, for: chat)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // create a new msg object
        let message = Message(content: text)
        // write msg to database
        sendMessage(message)
        // notify JSQMsgViewCOntroller that finished sending , this clear text field , prevent duplicate msg being sent
        finishSendingMessage()
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
    }
    
}

// MARK: - UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toChat", sender: self)
    }
}

// MARK: - Navigation

extension ChatListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat",
            let destination = segue.destination as? ChatViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            destination.chat = chats[indexPath.row]
        }
    }
}
