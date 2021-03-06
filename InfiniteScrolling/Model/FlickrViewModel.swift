//
//  FlickrViewModel.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 14.02.2021.
//

import Foundation
import UIKit

class FlickrViewModel: FeedViewModel {
    static let baseUrl = "https://www.flickr.com/services/rest/"
    static let apiKey = "52344e91e167a08be273a34de65c5510"
    private static let searchParameters = ["api_key": FlickrViewModel.apiKey,
                             "method": "flickr.photos.search",
                             "text": "cinema",
                             "privacy_filter": "1",
                             "safe_search": "1",
                             "media": "photos",
                             "per_page": "100",
                             "format": "json",
                             "nojsoncallback": "1",
                             "extras": "url_q,url_c"]
    private static let exifParameters = ["api_key": FlickrViewModel.apiKey,
                             "method": "flickr.photos.getExif",
                             "format": "json",
                             "nojsoncallback": "1"]

    // cache images
    private lazy var imageCache = NSCache<NSString, UIImage>()
    // cache exif
    private lazy var exifCache = NSCache<NSString, PhotoExif>()
    
    private var items: [Item] = []
    private var totalPagesCount: Int = 1
    private var currentPage: Int = 0
    private var aGroup = DispatchGroup()
    
    // Get count of item's array
    func getCount() -> Int {
        return items.count
    }
    
    // Get item
    func getItem(_ i: Int) -> Item {
        return items[i]
    }
    
    // Loading and saving list of items
    func getNextPage(_ refresh: @escaping(()->Void)) {
        // check number of page
        if currentPage < totalPagesCount { currentPage += 1 } else {
            DispatchQueue.main.async {
                refresh()
            }
            return
        }
        
        // get current page with item's list
        var searchParams = FlickrViewModel.searchParameters
        searchParams["page"] = String(currentPage)
        NetworkModel.shared.sendRequest(FlickrViewModel.baseUrl,
                    method: "GET",
                    parameters: searchParams,
                    headers: [:]) { [weak self]
            responseSearch, errorSearch in
            guard let self = self else { return }
            
            if (errorSearch == nil) {
                // count of pages and array of fotos
                if let responseSearch = responseSearch,
                   let photos = responseSearch["photos"] as? Dictionary<String, Any>,
                   let pages = photos["pages"] as? Int,
                   let photoArr = photos["photo"] as? Array<Any> {
 
                    self.totalPagesCount = pages
                    let photoArrDic = photoArr.compactMap({ $0 as? Dictionary<String, Any> })
                    
                    var bufferItems: [Item] = []
                    // let us convert from Dictionary<String, Any> to Item every element
                    for pic in photoArrDic {
                        // append only items with id and small images
                        if let id = pic["id"] as? String,
                           let urlSmallStr = pic["url_q"] as? String,
                           let urlSmall = URL(string: urlSmallStr),
                           let urlBig = URL(string: pic["url_c"] as? String ?? urlSmallStr)  {
                            bufferItems.append(Item(id: id,
                                                    secret: pic["secret"] as? String,
                                                    urlSmall: urlSmall,
                                                    smallImage: nil,
                                                    urlBig: urlBig,
                                                    bigImage: nil,
                                                    exif: nil,
                                                    downloadDate: .init()))
                        }
                    }
                    // We form a group of asynchronous operations for loading images and exif
                    for item in bufferItems {
                        // Big image
                        self.aGroup.enter()
                        self.asyncLoadImage(imageURL: item.urlBig,
                                            runQueue: DispatchQueue.global(),
                                            completionQueue: DispatchQueue.main) {
                            [weak self] result, error in
                            guard let self = self else { return }
                            guard let image1 = result else {
                                self.aGroup.leave()
                                return
                            }
                            item.setBigImage(image1)
                            self.aGroup.leave()
                        }
                        // Small image
                        self.aGroup.enter()
                        self.asyncLoadImage(imageURL: item.urlSmall,
                                            runQueue: DispatchQueue.global(),
                                            completionQueue: DispatchQueue.main) {
                            [weak self] result, error in
                            guard let self = self else { return }
                            guard let image1 = result else {
                                self.aGroup.leave()
                                return
                            }
                            item.setSmallImage(image1)
                            self.aGroup.leave()
                        }
                        // Exif
                        self.aGroup.enter()
                        self.getExif(id: item.id, secret: item.secret) {
                            photoExif in
                            item.setExif(photoExif)
                        }
                    }
                    // Callback block for the whole group
                    self.aGroup.notify(queue: DispatchQueue.main) {
                        [weak self] in
                        guard let self = self else { return }
                        self.items.append(contentsOf: bufferItems.filter({$0.bigImage != nil && $0.smallImage != nil }))
                        refresh()
                    }
                } else {
                    DispatchQueue.main.async {
                        refresh()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    refresh()
                }
            }
        }
    }
    
    // Loading and saving an image
    func asyncLoadImage(imageURL: URL,
                        runQueue: DispatchQueue,
                        completionQueue: DispatchQueue,
                        completion: @escaping (UIImage?, Error?) -> ()) {
        runQueue.async {
            do {
                let data = try Data(contentsOf: imageURL)
                completionQueue.async {
                    completion(UIImage(data: data), nil)
                }
            } catch let error {
                print("catch error")
                completionQueue.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    // Loading and saving an Exif of item
    func getExif(id: String, secret: String?, saving: @escaping ((PhotoExif)->Void)) {
        //var key: NSString
        
        // try get exif from cache
        /*if let secret = secret {
            key = NSString(string: id + secret)
        } else {
            key = NSString(string: id)
        }*/

        // maybe it's in cache yet
        /*if let cacheResult = exifCache.object(forKey: key) {
            DispatchQueue.main.async() {
                saving(cacheResult)
            }
            return
        }*/
        
        // prepare parameters of networking request
        var exifParams = FlickrViewModel.exifParameters
        exifParams["photo_id"] = id
        exifParams["secret"] = secret
        
        // networking request exif
        NetworkModel.shared.sendRequest(FlickrViewModel.baseUrl,
                    method: "GET",
                    parameters: exifParams,
                    headers: [:]) {
            [weak self] responseExif, errorExif in
            guard let self = self else { return }
            defer {
                self.aGroup.leave()
            }
            
            if (errorExif == nil) {
                // success response
                if let responseExif = responseExif,
                   let photo = responseExif["photo"] as? Dictionary<String, Any>,
                   let exifArrayAny = photo["exif"] as? Array<Any> {
                    var exifs: [Exif] = []
                    for exifAny in exifArrayAny {
                        if let exifTag = exifAny as? Dictionary<String, Any>,
                           let raw = exifTag["raw"] as? Dictionary<String, String> {
                            let clean = exifTag["clean"] as? Dictionary<String, String>
                            exifs.append(Exif(tagspace: exifTag["tagspace"] as? String,
                                            label: exifTag["label"] as? String,
                                            raw: raw["_content"],
                                            clean: clean?["_content"]))
                        }
                    }
                    DispatchQueue.main.async() {
                        let photoExif = PhotoExif(exifs)
                        //self.exifCache.setObject(photoExif, forKey: key)
                        saving(photoExif)
                    }
                }
            } else {
                DispatchQueue.main.async() {
                    saving(PhotoExif([]))
                }
            }
        }
    }
    
    // Loading and saving a image of item
    /*func getImage(url: String, saving: @escaping ((UIImage)->Void)) {
        guard let urlURL = URL(string: url) else { return }
        
        if let cacheImage = imageCache.object(forKey: NSString(string: url)) {
            DispatchQueue.main.async() {
                saving(cacheImage)
            }
            return
        }
        
        URLSession.shared.dataTask(with: urlURL) {
            [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data),
                let self = self
                else {
                return
            }
            
            DispatchQueue.main.async() {
                self.imageCache.setObject(image, forKey: NSString(string: url))
                saving(image)
            }
        }.resume()
    }*/
}

extension FlickrViewModel: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

