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
    
    // functions
    
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
