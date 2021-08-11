//
//  ChatAppUser.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-11.
//

import Foundation

struct ChatAppUser
{
    // properties
    private(set) internal var firstName : String
    private(set) internal var lastName  : String
    private(set) internal var email : String
    internal var safeEmail : String {
        var newEmailToReturn = email.replacingOccurrences(of: "@", with: "-")
        newEmailToReturn = newEmailToReturn.replacingOccurrences(of: ".", with: "-")
        return newEmailToReturn
    }
    
    // initalizers
    init(firstNameVal : String, lastNameVal : String, emailVal : String)
    {
        firstName = firstNameVal
        lastName = lastNameVal
        email = emailVal
    }
}
