//
//  DateFormatter.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-09-08.
//

import Foundation

struct DateFormatterHandler
{
    // properties
    static let shared = DateFormatterHandler()
    
    
    public static let dateformatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public func returnDateAsString(dateToConvert : Date) -> String
    {
        let dateToConvertAsString = Self.dateformatter.string(from: dateToConvert)
        return dateToConvertAsString
    }
    
    
}
