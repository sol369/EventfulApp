//
//  ChatService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import  FirebaseDatabase


class ChatService {
    static func sendMessage(_ message: Comments, eventKey: String,success: ((Bool) -> Void)? = nil) {
        
        var multiUpdateValue = [String : Any]()

        let messagesRef = Database.database().reference().child("comments").child(eventKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["Comments/\(eventKey)/\(messageKey)"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
    }
    
    
    
    static func observeMessages(forChatKey eventKey: String, completion: @escaping (DatabaseReference, Comments?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child(eventKey)
        return messagesRef.observe(.childAdded, with: { snapshot in
            guard let message = Comments(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            
            completion(messagesRef, message)
        })
    }
}