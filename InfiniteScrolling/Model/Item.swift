//
//  Item.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 14.02.2021.
//

import Foundation
import UIKit

class Item {
    private static let exifParameters = ["api_key": FlickrViewModel.apiKey,
                             "method": "flickr.photos.getExif",
                             "format": "json",
                             "nojsoncallback": "1"]
    
    private var id: String
    private var secret: String
    var urlSmall: String
    var urlBig: String?
    var downloadDate: Date
    var exif: [String: String]
    
    
    init(id: String, secret: String, urlSmall: String, urlBig: String?, downloadDate: Date, exif: [String: String]) {
        self.id = id
        self.secret = secret
        self.urlSmall = urlSmall
        self.urlBig = urlBig
        self.downloadDate = downloadDate
        self.exif = exif
    }
    
    func loadExif(_ refresh: @escaping(()->Void)) {
        var exifParams = Item.exifParameters
        exifParams["photo_id"] = self.id
        exifParams["secret"] = self.secret
        
        NetworkModel.shared.sendRequest(FlickrViewModel.baseUrl,
                    method: "GET",
                    parameters: exifParams,
                    headers: [:]) {
            responseExif, errorExif in
            if (errorExif == nil) {
                if let responseExif = responseExif,
                   let photo = responseExif["photo"] as? Dictionary<String, Any>,
                   let exifArrayAny = photo["exif"] as? Array<Any> {
                    let exifArrayTyped = exifArrayAny.compactMap({ $0 as? Dictionary<String, Any> })
                    for ex in exifArrayTyped {
                        if let label = ex["label"] as? String,
                           let raw = ex["raw"] as? Dictionary<String, Any>,
                           let content = raw["_content"] as? String {
                            self.exif[label] = content
                        }
                    }
                    refresh()
                }
            }
        }
    }
    
    func cacheImages() {
        UIImageView.cacheImage(self.urlSmall)
        if let url = self.urlBig { UIImageView.cacheImage(url) }
    }
}
