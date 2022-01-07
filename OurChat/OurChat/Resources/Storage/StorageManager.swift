//
//  StorageManager.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-19.
//

import Foundation
import FirebaseStorage

final class StorageManager
{
    // properties
    static let shared = StorageManager()
    let storageReference = Storage.storage().reference()
    
    // functions
    
    /// Only UploadsProfilePictureToCloud and if successful we should get back the downloadURLAsAString
    internal typealias uploadProfilePictureCompletion = (Result<String,Error>) -> Void
    internal func uploadProfilePictureToStorage(dataToUpload : Data, fileName : String, completion : @escaping uploadProfilePictureCompletion)
    {
        let referenceToChildURL = storageReference.child("images/"+fileName)
        
        referenceToChildURL.putData(dataToUpload, metadata: nil) { _, error in
            guard error == nil else{
                completion(.failure(StorageError.uploadFileError))
                return
            }
            // success
            referenceToChildURL.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    completion(.failure(StorageError.downloadURLError))
                    return
                }
                // success in getting the downloadURL
                let downloadURLAsString = downloadURL.absoluteString
                completion(.success(downloadURLAsString))
                return
            }
        }
    }
    
    /// gets the download URL from the path provided
    internal func getDownloadURL(for path : String, completionHandler : @escaping (Result<String,Error>) -> Void)
    {
        let reference = storageReference.child(path)
        reference.downloadURL { url, error in
            guard let safeURl = url, error == nil else{
                print("There was an error in getting the downloadURL fro the path.")
                completionHandler(.failure(StorageError.downloadURLError))
                return
            }
            // here it was successful so we want to pass the downloadURL as a string into the closure
            completionHandler(.success(safeURl.absoluteString))
        }
    }
    
    
    /// uploads the image to the conversations subfolder whose id matches the conversation id provided
    internal typealias uploadImageToConversationCompletion = (Result<String,Error>) -> Void
    
    internal func uploadImageToConversationStorage(data : Data, fileName : String, conversationID : String ,completion : @escaping uploadImageToConversationCompletion)
    {
        // so first thing is first and we want to define the path
        //let path = "conversations/\(conversationID)" + fileName
        let path = ("conversations/\(conversationID)/\(fileName)")
        // now that we have our path we want to put data at this location
        storageReference.child(path).putData(data, metadata: nil) {[weak self] _, error in
            guard let strongSelf = self else {return}
            guard error == nil else {
                completion(.failure(StorageError.uploadFileError))
                return
            }
            // success so now we want to get the download URL back
            print("Successfully put our data at the specified location")
            strongSelf.getDownloadURL(for: path) { result in
                switch result
                {
                case .success(let downloadURlAsString):
                    completion(.success(downloadURlAsString))
                
                case .failure(let downloadURLError):
                    completion(.failure(downloadURLError))
                }
            }
        }
    }
    
    internal typealias uploadVideoToConversationCompletion = (Result<String,Error>) -> Void
    internal func uploadVideoToConversationStorage(videoURL : URL, fileName : String, conversationID : String, completion : @escaping uploadVideoToConversationCompletion)
    {
        let path = ("conversations/\(conversationID)/\(fileName)")
        storageReference.child(path).putFile(from: videoURL, metadata: nil) {[weak self] metaData, error in
            guard let strongSelf = self else {return}
            guard metaData != nil, error == nil else {
                completion(.failure(StorageError.uploadFileError))
                return
            }
            // success so now we want to get the downloadURL from our file
            strongSelf.getDownloadURL(for: path) { result in
                switch result
                {
                case .success(let downloadURL):
                    completion(.success(downloadURL))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        
    }

    
    
    
    
    
    
}
