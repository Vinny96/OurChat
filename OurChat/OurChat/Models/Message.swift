//
//  Message.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-08-31.
//

import Foundation
import MessageKit

struct Message : MessageType
{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension MessageKind
{
    var messageKindString : String
    {
        switch self
        {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
        
        
    }
    
    
}
