//
//  FlickrViewModel.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 14.02.2021.
//

import Foundation
class FlickrViewModel: FeedViewModel {
    static let baseUrl = "https://www.flickr.com/services/rest/"
    static let apiKey = "52344e91e167a08be273a34de65c5510"
    private static let searchParameters = ["api_key": FlickrViewModel.apiKey,
                             "method": "flickr.photos.search",
                             "text": "automobile",
                             "privacy_filter": "1",
                             "safe_search": "1",
                             "media": "photos",
                             "per_page": "100",
                             "format": "json",
                             "nojsoncallback": "1",
                             "extras": "url_q,url_c"]
    
    
    private var totalCount: Int
    private var page: Int
    
    init() {
        self.totalCount = 1
        self.page = 0
    }
    
    func getPage(saving: @escaping (([Item]) -> Void),
                 crash: @escaping(()->Void),
                 refresh: @escaping (()->Void)) {
        if page < totalCount { page = page + 1 } else { return }
        
        var searchParams = FlickrViewModel.searchParameters
        searchParams["page"] = String(page)
        NetworkModel.shared.sendRequest(FlickrViewModel.baseUrl,
                    method: "GET",
                    parameters: searchParams,
                    headers: [:]) {
            responseSearch, errorSearch in
            if (errorSearch == nil) {
                // temperature and current weather conditions
                if let responseSearch = responseSearch,
                   let photos = responseSearch["photos"] as? Dictionary<String, Any>,
                   let pages = photos["pages"] as? Int,
                   let photo = photos["photo"] as? Array<Any> {
 
                    self.totalCount = pages
                    let p1 = photo.compactMap({ $0 as? Dictionary<String, Any> })
                    
                    let items = p1.compactMap({
                        pic -> Item in
                        let item = Item(
                            id: pic["id"] as? String ?? "",
                            secret: pic["secret"] as? String ?? "",
                            urlSmall: pic["url_q"] as? String ?? "",
                            urlBig: pic["url_c"] as? String,
                            downloadDate: .init(),
                            exif: [:])
                        item.cacheImages()
                        item.loadExif(refresh)
                        return item
                    })
                    DispatchQueue.main.async {
                        saving(items)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    crash()
                }
            }
        }
    }
}

extension FlickrViewModel: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

