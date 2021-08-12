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
        
        databaseReference.child(safeEmail).setValue(valueToInsert) { error, _ in
            guard error == nil else
            {
                completion(.failure(error!))
                return
            }
            // success
            let successString = "Insertion was successful"
            completion(.success(successString))
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
    
    
}
