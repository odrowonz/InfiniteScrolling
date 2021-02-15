//
//  FeedViewModel.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 14.02.2021.
//

import Foundation

protocol FeedViewModel {
    // Saving page's count and list of images
    func getPage(saving: @escaping (([Item])->Void), crash: @escaping(()->Void), refresh: @escaping (()->Void))
}
