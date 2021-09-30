//
//  DatabaseManager.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-11.
//

import Foundation
import FirebaseDatabase

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
    /// Creates a new conversation with target user email and with first message sent
    public func createNewConversation(with otherUserEmail : String, otherUserName : String, firstMessage : Message, completion : @escaping (Bool) -> Void)
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
                strongSelf.databaseReference.child(currentSafeEmail).child("conversations").setValue(conversationsDict) {[weak self] error, _ in
                    guard let strongSelf = self else {return}
                    guard error == nil else
                    {
                        print("There was an error in uploading the converationsDict to Firebase: \(error!)")
                        completion(false)
                        return
                    }
                    // success
                    print("Uploading the conversationsDict to Firebase was a succes")
                    // so we need to implement logic in which if the conversationID exists in the database we append to it. If not we have to create the conversationID child. 
                    completion(true)
                }
            }
            else // this block will get triggered for the first ever user
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
                    
                    strongSelf.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, otherUserName: otherUserName) { result in
                        switch result
                        {
                        case true:
                            completion(true)
                        
                        case false:
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    /// Fetches and returns all conversations for the user wtih passed in email
    public func getAllConversations(for email : String, completion : @escaping (Result<[Conversation],Error>) -> Void)
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
    public func getAllMessagesForConversation(with id : String, completion : @escaping(Result<String,Error>) -> Void)
    {
        // so again we are going pass in our Conversation object for the ID and we will change the Result as well once we create our conversation object
    }

    
    /// Sendsa a message with target conversation and message 
    public func sendMessageToConversation(to conversation : Conversation, message : Message, completion : @escaping (Bool) -> Void)
    {
        // again we are going to place a string as the type for conversation for now but this will change.
        
    }
    
    /// The method below will create the conversation as a child in the database so messages  can be sent to that conversation
    private func finishCreatingConversation(conversationID : String, firstMessage : Message, otherUserName : String ,completion : @escaping(Bool) -> Void)
    {
        let firstMessageDateAsString = DateFormatterHandler.shared.returnDateAsString(dateToConvert: firstMessage.sentDate)
        guard let currentUserSafeEmail = UserDefaults.standard.value(forKey: UserDefaultKeys.loggedInUserSafeEmail) else {
            
            completion(false)
            return
        }
        
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
         
        let messageObjectToAppend : [String : Any] = [
            "date" : firstMessageDateAsString,
            "id" : firstMessage.messageId,
            "other_user_name" : otherUserName,
            "type" : firstMessage.kind.messageKindString,
            "content" :messageToAppend ,
            "sender_email" : currentUserSafeEmail,
            "is_read" : false
        ]
        
        let messagesDictionary : [String : [String : Any]] = [
            "messages" : messageObjectToAppend]
                
        databaseReference.child(conversationID).setValue(messagesDictionary) { error, _ in
            guard error == nil else {
                print("Error in uploading the messagesDictionary to firebase")
                completion(false)
                return
            }
            // success
            print("Success in uploading the messagesDiciontary to firebase.")
            completion(true)
        }
        
    }
}

