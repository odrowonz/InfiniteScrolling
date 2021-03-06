//
//  Item.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 14.02.2021.
//

import Foundation
import UIKit

class Item {
    
    var id: String
    var secret: String?
    var urlSmall: URL
    var smallImage: UIImage?
    var urlBig: URL
    var bigImage: UIImage?
    var exif: PhotoExif?
    var downloadDate: Date
    
    init(id: String, secret: String?, urlSmall: URL, smallImage: UIImage?, urlBig: URL, bigImage: UIImage?, exif: PhotoExif?, downloadDate: Date) {
        self.id = id
        self.secret = secret
        self.urlSmall = urlSmall
        self.smallImage = smallImage
        self.urlBig = urlBig
        self.bigImage = bigImage
        self.exif = exif
        self.downloadDate = downloadDate
    }
    
    func setSmallImage(_ smallImage: UIImage) {
        self.smallImage = smallImage
    }
    
    func setBigImage(_ bigImage: UIImage) {
        self.bigImage = bigImage
    }
    
    func setExif(_ exif: PhotoExif) {
        self.exif = exif
    }
    
    /*func cacheImages() {
        UIImageView.cacheImage(self.urlSmall)
        if let url = self.urlBig { UIImageView.cacheImage(url) }
    }*/
}
