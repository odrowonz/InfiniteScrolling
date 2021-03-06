//
//  ApiError.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 06.03.2021.
//

enum ApiError: Error {
    case unauthorized
    case notFound
    case invalidModel
    case internalServer
}
