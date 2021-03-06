//
//  Exif.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 21.02.2021.
//

import Foundation
class Exif {
    var tagspace: String?
    var label: String?
    var raw: String?
    var clean: String?
    
    init(tagspace: String?, label: String?, raw: String?, clean: String?) {
        self.tagspace = tagspace
        self.label = label
        self.raw = raw
        self.clean = clean
    }
}
