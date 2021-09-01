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
    public typealias uploadProfilePictureCompletion = (Result<String,Error>) -> Void
    public func uploadProfilePictureToStorage(dataToUpload : Data, fileName : String, completion : @escaping uploadProfilePictureCompletion)
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
    
    
    
    
}
