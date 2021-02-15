//
//  NetworkModel.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 14.02.2021.
//

import Foundation
class NetworkModel {
    static var shared: NetworkModel = {
            let instance = NetworkModel()
            return instance
        }()
    
    private init() {}
    
    // Send request and save response
    func sendRequest(_ url: String,
                     method: String,
                     parameters: [String: String],
                     headers: [String: String],
                     completion: @escaping ([String: Any]?, Error?) -> Void) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        
        for (value, header) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            DispatchQueue.main.async {
                completion(responseObject, nil)
            }
        }.resume()
    }
}

extension NetworkModel: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
