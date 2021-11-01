//
//  DatabaseManager.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-11.
//

import Foundation
import FirebaseDatabase
import MessageKit
import UIKit

final class DatabaseManager
{
    // properties
    static let shared = DatabaseManager()
    private let databaseReference = Database.database().reference()

    
    // MARK: - Account Management
    
    /// inserts user into database
    public func writeNewUserToDB(chatAppUserToInsert : ChatAppUser, completion : @escaping (Result<String,Error>) -> Void)
    {
        // so we want the email to be the childNode
        let safeEmail = chatAppUserToInsert.safeEmail
        let firstName = chatAppUserToInsert.firstName
        let lastName = chatAppUserToInsert.lastName
        
        let valueToInsert : [String : Any] = [
            "firstName" : firstName,
            "lastName" : lastName
        ]
        
        // here we are writing our new user to the database and this is used solely for checking if the user exists
        databaseReference.child(safeEmail).setValue(valueToInsert) { error, _ in
            guard error == nil else
            {
                completion(.failure(error!))
                return
            }
        }
        
        // so now we need to see if the collection for users exists and if it does we append to that. If it does not we have to create it
        databaseReference.child("users").observeSingleEvent(of: .value) {[weak self] dataSnapShot in
            // so we need to check to see if a value exists here and if it does we can just create a new collection and append it. If not we will have to create the collection.
            guard let strongSelf = self else{return}

            if var usersCollection = dataSnapShot.value as? [[String : String]]
            {
                // so here the users collection exists
                let arrayToAppend : [String : String] = [
                    "safe_email" : chatAppUserToInsert.safeEmail,
                    "full_name" : chatAppUserToInsert.firstName + " " + chatAppUserToInsert.lastName
                ]
                
                usersCollection.append(arrayToAppend)
                strongSelf.databaseReference.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                    guard error == nil else
                    {
                        print("There was an error in writing the newUser to the child Users in the database")
                        completion(.failure(error!))
                        return
                    }
                    // success
                    let successString = "Successfully wrote the newUser to the database and to the users child node in the database"
                    completion(.success(successString))
                })
                
            }
            else
            {
                // so here the users collection does not exist
                var newUsersCollection : [[String : String]] = [[String : String]]()
                let nestedArrayToAppend : [String : String] = [
                    "safe_email" :  chatAppUserToInsert.safeEmail,
                    "full_name" : chatAppUserToInsert.firstName + " " + chatAppUserToInsert.lastName
                ]
                newUsersCollection.append(nestedArrayToAppend)
                strongSelf.databaseReference.child("users").setValue(newUsersCollection) { error, _ in
                    guard error == nil else {
                        print("There was an error in writing the newUsersCollection to the users child node in the database")
                        completion(.failure(error!))
                        return
                    }
                    // success
                    let successString = "Successfully created a newUsersCollection, appended the first users to this collection and wrote the newUsersCollection to the database"
                    completion(.success(successString))
                }
            }
        }
    }
    
    /// checks if the email already exists in the database by querying the database for the user's email.
    public func checkIfUserExistsInDB(chatAppUserToCheck : ChatAppUser, completion : @escaping (Bool) -> Void)
    {
        // so the userID is going to be the safeEmail
        let userID = chatAppUserToCheck.safeEmail
        databaseReference.child(userID).observeSingleEvent(of: .value) { dataSnapShot in
            guard dataSnapShot.exists() else {
                completion(false)
                return
            }
            // success
            completion(true)
        }
        
    }
    
    /// gets all of the users from the database
    public func getAllUsersFromDB(completion : @escaping (Result<[[String : String]], Error>) -> Void)
    {
        databaseReference.child("users").observeSingleEvent(of: .value) { dataSnapShot in
            guard let usersCollection = dataSnapShot.value as? [[String : String]] else {
                print("Not able to fetch the usersCollection from the users child node in the DB")
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            // success
            completion(.success(usersCollection))
        }
    }
}



// MARK: - Sending Mesages/Conversations
extension DatabaseManager
{
    /// Creates a new conversation for the sending user with target user email and with first message sent. This functions gets called the first time the user ever sends a message
    internal func createNewConversation(with otherUserEmail : String, otherUserName : String, firstMessage : Message, completion : @escaping (Bool) -> Void)
    {
        // so here we have to check if the conversations key exists for the childNode and if it does not exist we have to create it
        guard let currentSafeEmail = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) as? String else {return}
        
        databaseReference.child("\(currentSafeEmail)").observeSingleEvent(of: .value) {[weak self] dataSnapShot in
            guard let userNode = dataSnapShot.value as? [String : Any] else{
                // so here this means that the userNode does not exist and this should not happen
                print("The user does not exist")
                completion(false)
                return
            }
            guard let strongSelf = self else{return}
            
            // so here we have successfully found the userNode and we need to check to see if the conversations key exists or not.
           
            let firstMessageDateAsString = DateFormatterHandler.shared.returnDateAsString(dateToConvert: firstMessage.sentDate)
            
            // so here we are handling the multiple message types
            var messageToAppend = " "
            switch firstMessage.kind
            {
            case .text(let messageText):
                messageToAppend = messageText
           
            case .attributedText(_):
                break
            
            case .photo(_):
                break
            
            case .video(_):
                break
            
            case .location(_):
                break
            
            case .emoji(_):
                break
            
            case .audio(_):
                break
            
            case .contact(_):
                break
            
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            
            let newConversationData : [String : Any] = [
                "conversation_id" : "conversation_\(firstMessage.messageId)",
                "other_user_email" : otherUserEmail,
                "other_user_name" : otherUserName, // we need this as we need the others users name to show in the conversation list.
                "latest_message" : [
                    "date" : firstMessageDateAsString,
                    "message" : messageToAppend,
                    "is_read" : false // a new message is not read by default
                ]
            ]
            
            
            if var conversationsDict = userNode["conversations"] as? [[String : Any]]
            {
                // the conversationsDict exists so we want to append a new conversation to it
                conversationsDict.append(newConversationData)
                strongSelf.databaseReference.child(currentSafeEmail).child("conversations").setValue(conversationsDict) {error, _ in
                    guard error == nil else
                    {
                        print("There was an error in uploading the converationsDict to Firebase: \(error!)")
                        completion(false)
                        return
                    }
                    // success
                    print("Uploading the conversationsDict to Firebase was a succes")
                    guard let conversationID = newConversationData["conversation_id"] as? String else {return}
                    guard let otherUserName = newConversationData["other_user_name"] as? String else {return}
                    guard let otherUserEmail = newConversationData["other_user_email"] as? String else {return}
                   
                    print("Running after the guard statements")
                    print(strongSelf)
                    strongSelf.createNewConversationForRecipient(otherUserName: otherUserName, otherUserEmail: otherUserEmail, message: firstMessage) {result in
                        switch result
                        {
                        case true:
                            print("Successfully created a new conversation for recipient")
                            strongSelf.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, otherUserName: otherUserName) { creatingConversationResult in
                                switch creatingConversationResult
                                {
                                case true:
                                    print("Successfully finished creating conversation")
                                    completion(true)
                                
                                case false:
                                    print("There was an error in finishing createing conversation")
                                    completion(false)
                                }
                            }
                        
                        case false:
                            print("Error in creating new conversation for recipient")
                            completion(false)
                        }
                    }
                }
            }
            else // this block will get triggered the first time a user ever sends a message
            {
                // the converationsDict must be created
                var conversationsDict : [[String : Any]] = [[String : Any]]()
                conversationsDict.append(newConversationData)
                strongSelf.databaseReference.child(currentSafeEmail).child("conversations").setValue(conversationsDict) { error, _ in
                    guard error == nil else
                    {
                        print("There was an error in creating a new conversationsDict, appending new conversation data to it and uploading it to Firebase: \(error!)")
                        completion(false)
                        return
                    }
                    // success
                    print("Successfully appended new conversations to a newly created conversationsDict")
                    guard let conversationID = newConversationData["conversation_id"] as? String else {return}
                    
                    
                    // now we want to createNewConversation for recipient and also call finish creatingConversation as at this point the conversation child between these two users does not exist
                    strongSelf.createNewConversationForRecipient(otherUserName: otherUserName, otherUserEmail: otherUserEmail, message: firstMessage) { result in
                        switch result
                        {
                        case true:
                            // here we need to call logic that will check if the conversation child does exist in the db / does not exist in the db
                            print("Successfully created new conversation for reecipient")
                            strongSelf.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, otherUserName: otherUserName) { finishCreatingConversationResult in
                                switch finishCreatingConversationResult
                                {
                                case true:
                                    print("Successfully finished creating conversation child in DB.")
                                    completion(true)
                                case false:
                                    print("Error in creating conversation child in DB")
                                    completion(false)
                                }
                            }
                            
                        case false:
                            print("Error in creatingNewConversation for recipient")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    /// Creates a new conversations for the recipient user with target user email and first message sent. This function does not have logic for appending the message to the conversation child in the Database as the createNewConversationFunction will take care of it.
    private func createNewConversationForRecipient(otherUserName : String, otherUserEmail : String , message : Message, completion : @escaping(Bool) -> Void)
    {
        // the first thing we want to do is check to see if the other user exists and cast it to a dictionary of [[String : Any]]
        databaseReference.child(otherUserEmail).observeSingleEvent(of: .value) {[weak self] dataSnapShot in
            guard let userNode = dataSnapShot.value as? [String : Any] else {
                print("User does not exist and this should not happen")
                completion(false)
                return
            }
            // so now that we have verified that the user exists in the database we now want to see if the conversations dict exists in dictionary
            guard let strongSelf = self else {return}
            var messageToAppend = " "
            switch message.kind
            {
            case .text(let messageText):
                messageToAppend = messageText
           
            case .attributedText(_):
                break
            
            case .photo(_):
                break
            
            case .video(_):
                break
            
            case .location(_):
                break
            
            case .emoji(_):
                break
            
            case .audio(_):
                break
            
            case .contact(_):
                break
            
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let senderEmail = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) as? String else {return} // so here the sender is the logged in user so the other UserEmail for the recipient is going to be the currently logged in user
            guard let senderName = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserName) as? String else {
                print("sender name is nil")
                return}
            let messageDateAsString = DateFormatterHandler.shared.returnDateAsString(dateToConvert: message.sentDate)
            
            
            let newConversationData : [String : Any] = [
                "conversation_id" : "conversation_\(message.messageId)",
                "other_user_email" : senderEmail,
                "other_user_name" : senderName, // we need to cache the current logged in users name which we will use to populate this field
                "latest_message" : [
                    "date" : messageDateAsString,
                    "message" : messageToAppend,
                    "is_read" : false // a new message is not read by default
                ]
            ]
            
            if var conversationsDict = userNode["conversations"] as? [[String : Any]]
            {
                // so here the conversationsDict does exist
                print("Running here")
                conversationsDict.append(newConversationData)
                strongSelf.databaseReference.child(otherUserEmail).child("conversations").setValue(conversationsDict) { error, _ in
                    guard error == nil else {
                        print("There was an error in creating the new Conversation for the recipient: \(error!)")
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
            else
            {
                // here the conversations dict does not exist for the user
                print("Running here as the conversations dict does not exist")
                var conversationsDictToAppend : [[String : Any]] = [[String : Any]]()
                conversationsDictToAppend.append(newConversationData)
                strongSelf.databaseReference.child(otherUserEmail).child("conversations").setValue(conversationsDictToAppend) { error, _ in
                    guard error == nil else {
                        print("There was an error in creating the conversations dictionary for the recipient: \(error!) ")
                        completion(false)
                        return
                    }
                    completion(true)
                }
            
            }
        }
        
    }
    
    /// Fetches and returns all conversations for the user wtih passed in email
    internal func getAllConversations(for email : String, completion : @escaping (Result<[Conversation],Error>) -> Void)
    {
        databaseReference.child("\(email)/conversations").observe(.value) { dataSnapShot in
            guard let conversationsValue = dataSnapShot.value as? [[String : Any]] else {
                completion(.failure(DatabaseManagerError.failedToFetch))
                print("There was an error in getAllConversations:\(DatabaseManagerError.failedToFetch)")
                return
            }
            // success so here we got the conversations
            let conversations : [Conversation] = conversationsValue.compactMap({ dictionary in
                guard let conversationID = dictionary["conversation_id"] as? String,
                let otherUserEmail = dictionary["other_user_email"] as? String,
                let otherUserName = dictionary["other_user_name"] as? String,
                let latestMessageDict = dictionary["latest_message"] as? [String : Any],
                let date = latestMessageDict["date"] as? String,
                let isRead = latestMessageDict["is_read"] as? Bool,
                let latestMessage = latestMessageDict["message"] as? String
                else {return nil}
                
                // so here the unwrapping is successful so we can create the conversationModel
                let latestMessageObject = LatestMessage(date: date, message: latestMessage, isRead: isRead)
                let latestConversation = Conversation(otherUserName: otherUserName, conversationID: conversationID, latestMessage: latestMessageObject, otherUserEmail: otherUserEmail)
                return latestConversation
            })
            completion(.success(conversations))
        }
    }
    
    /// Gets all messages for a given conversation
    internal func getAllMessagesForConversation(with id : String, completion : @escaping(Result<[Message],Error>) -> Void)
    {
        // so again we are going pass in our Conversation object for the ID and we will change the Result as well once we create our conversation object
        let path = "\(id)/messages"
        databaseReference.child(path).observe(.value) { dataSnapShot in
            guard let messagesValue = dataSnapShot.value as? [[String : Any]] else {
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            // success
            // so here we are getting an array of String:Any which we then need to map into a message object
            let messages : [Message] = messagesValue.compactMap({dictionary in
                guard let content = dictionary["content"] as? String,
                      let date = dictionary["date"] as? String,
                      let id = dictionary["id"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let otherUserName = dictionary["other_user_name"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateStringAsDate = DateFormatterHandler.shared.returnDateFromString(dateAsStringToConvert: date)
                else {
                    print("Running in the else block")
                    return nil
                }
                
                // so here the unwrapping is scucessfull so we can create the messageModel
                let sender = Sender(photoURLAsString: "", senderId: senderEmail, displayName: otherUserName)
                let messageToReturn = Message(sender: sender , messageId: id, sentDate: dateStringAsDate, kind: .text(content))
                return messageToReturn
            })
            completion(.success(messages))
        }
    }

    
    /// Sends a message with target conversation and message 
    internal func sendMessageToConversation(to conversation : String, message : Message, recipientName : String, recipientEmail : String, completion : @escaping (Bool) -> Void)
    {
        // implementing sending the message to the conversations child in the database
        databaseReference.child("\(conversation)/messages").observeSingleEvent(of: .value) {[weak self] dataSnapShot in
            guard let strongSelf = self else {return}
            guard var currentMessages = dataSnapShot.value as? [[String : Any]] else {
                print("There was an error in sending the message to the user")
                completion(false)
                return
            }
            // success in getting the message child so now we are getting a  nested array of String:Any objects. Now we need to convert our message object into an string:any object that we can use to append it to our currentMessages object
            let messageDateAsString = DateFormatterHandler.shared.returnDateAsString(dateToConvert: message.sentDate)
            guard let senderEmail = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) as? String else {return}
           
            let messageObjToAppend = strongSelf.createMessageObjectForDB(message: message, messageDateAsString: messageDateAsString, recipientName: recipientName, senderEmail: senderEmail)
            
            currentMessages.append(messageObjToAppend)
            strongSelf.databaseReference.child(conversation).child("messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    print("There was an error in updating the conversation child in the database")
                    completion(false)
                    return
                }
                // success now we want to update the conversation object for both the loggedInUser and the recipient user.
                strongSelf.updateConversationObjectWithLatestMessage(userEmail: senderEmail, conversationID: conversation, latestMessageObjToAppend: messageObjToAppend) { result in
                    switch result
                    {
                    case true:
                        print("Success in  updating the conversations object for loggedInUser")
                        // now we have to update the conversations object for the recipient user
                        strongSelf.updateConversationObjectWithLatestMessage(userEmail: recipientEmail, conversationID: conversation, latestMessageObjToAppend: messageObjToAppend) { resultTwo in
                            switch resultTwo
                            {
                            case true:
                                print("Success in updating the conversation object for the recipient user")
                                completion(true)
                            
                            case false:
                                print("Failure in updating the conversation object for the recipient user.")
                                completion(false)
                            }
                        }
                    
                    case false:
                        print("Error in updating the conversations object for the loggedInUser and recipient user")
                        completion(false)
                    }
                }
            }
        }
        
    }
    
    ///Will update the entry in the users conversation object with the latest message that was sent. This is so this latest message can be shown in the conversations view controller
    private func updateConversationObjectWithLatestMessage(userEmail : String, conversationID : String, latestMessageObjToAppend : [String : Any] ,completion : @escaping (Bool) -> Void)
    {
        // first thing we need to do is define the path in which our converstions object would exist
        let path = ("\(userEmail)/conversations")
        databaseReference.child(path).observeSingleEvent(of: .value) {[weak self] dataSnapShot in
            guard let strongSelf = self else {return}
            guard var conversationsDict = dataSnapShot.value as? [[String : Any]] else {
                print("Running here as the conversationsDict is not present")
                completion(false)
                return
            }
            // now that we got the conversations array we have to check each dictionary to see if the conversationID matches the one from the parameter
            // we also want to keep track of the index so we can insert our new dict into that particular index
            var position = 0
            var dictToModify : [String : Any]?
            for dict in conversationsDict
            {
                guard let safeConvoID = dict["conversation_id"] as? String else {return}
                if(safeConvoID == conversationID)
                {
                    dictToModify = dict
                    break
                }
                position += 1
            }
            // so now that we know the position in the array in which we have to modify we can modify the dict directly and insert the modified dict into the conversations dict at the specified position
            guard var safeDictToModify = dictToModify else {
                print("There is no dictionary to modify")
                return
            }
            guard let dateAsString = latestMessageObjToAppend["date"] as? String else {return}
            guard let isRead = latestMessageObjToAppend["is_read"] as? Bool else {return}
            guard let message = latestMessageObjToAppend["content"] as? String else {return}
            
            let latestMessageToAddToConversation : [String : Any] = [
                "date" : dateAsString,
                "is_read" : isRead,
                "message" : message
            ]
            
            safeDictToModify["latest_message"] = latestMessageToAddToConversation
            conversationsDict[position] = safeDictToModify
            
            // now we need to set our new conversationsDict as the value at the path of userEmail/conversations
            strongSelf.databaseReference.child(path).setValue(conversationsDict) { error, _ in
                guard error == nil else {
                    print("The error is the following: \(error!)")
                    print("There is an error in updating the conversationsDict with the latest message.")
                    completion(false)
                    return
                }
                // success
                completion(true)
            }
        }
    }
    
    
    
    
    /// Will create the conversation as a child in the database so messages  can be sent to that conversation
    private func finishCreatingConversation(conversationID : String, firstMessage : Message, otherUserName : String ,completion : @escaping(Bool) -> Void)
    {
        let firstMessageDateAsString = DateFormatterHandler.shared.returnDateAsString(dateToConvert: firstMessage.sentDate)
        guard let currentUserSafeEmail = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) as? String else {
            completion(false)
            return
        }
        
        let messageObjectToAppend = createMessageObjectForDB(message: firstMessage, messageDateAsString: firstMessageDateAsString, recipientName: otherUserName, senderEmail: currentUserSafeEmail)
        
        // so here since this is a new conversation we have to create the messages array to append to
        var messagesArray : [[String : Any]] = [[String : Any]]()
        messagesArray.append(messageObjectToAppend)
        
        // now we want to set our messagesArray to be the value of the message child in the database
        let path = "\(conversationID)/messages"
        databaseReference.child(path).setValue(messagesArray) { error, _ in
            guard error == nil else {
                print("There was an error in setting our new messagesArray to be the value of the messages child: \(error!)")
                completion(false)
                return
            }
            // success
            print("Success in setting our messagesArray to be the value of the messages child. Succesfully finished creating conversation.")
            completion(true)
        }
    }
    
    /// this will create an object that will be used to update the conversation child in the database
    private func createMessageObjectForDB(message : Message, messageDateAsString : String, recipientName : String, senderEmail : String) -> [String : Any]
    {
        // we need to update this method later on to support the various different message types 
        var messageToAppend = " "
        switch message.kind
        {
        case .text(let messageText):
            messageToAppend = messageText
        
        case .attributedText(_):
            break
        
        case .photo(let mediaItem):
            if let targetURLAsString = mediaItem.url?.absoluteString
            {
                messageToAppend = targetURLAsString
            }
            break
        
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let messageObjectToAppend : [String : Any] = [
            "date" : messageDateAsString,
            "id" : message.messageId,
            "other_user_name" : recipientName,
            "type" : message.kind.messageKindString,
            "sender_email" : senderEmail,
            "content" : messageToAppend,
            "is_read" : false // this is always going to be false as we are just creating the messageObjectToAppend
        ]
        return messageObjectToAppend
    }
    
}


// Adding Functionality that will allow us to get data from any given path
extension DatabaseManager
{
    func getDataForPath(path : String, completion : @escaping(Result<Any,Error>) -> Void)
    {
        databaseReference.child(path).observeSingleEvent(of: .value) { dataSnapShot in
            guard let snapShotValue = dataSnapShot.value else
            {
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            // success
            completion(.success(snapShotValue))
        }
        
    }
    
    
}
