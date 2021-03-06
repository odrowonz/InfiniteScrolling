//
//  FeedViewModel.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 14.02.2021.
//

import Foundation
import UIKit

protocol FeedViewModel: AnyObject {
    // Get count of item's array
    func getCount() -> Int
    // Get item
    func getItem(_ i: Int) -> Item
    // Loading and saving list of items
    func getNextPage(_ refresh: @escaping(()->Void))
    //func getList(saving: @escaping (([Item])->Void), crash: @escaping(()->Void))
    // Loading and saving an Exif of item
    //func getExif(id: String, secret: String?, saving: @escaping ((PhotoExif)->Void))
    // Loading and saving a image of item
    //func getImage(url: String, saving: @escaping ((UIImage)->Void))
}
