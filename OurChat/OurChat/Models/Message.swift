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
