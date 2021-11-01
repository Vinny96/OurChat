//
//  MediaItem.swift
//  OurChat
//
//  Created by Vinojen Gengatharan on 2021-10-31.
//

import Foundation
import MessageKit

struct Media : MediaItem
{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
