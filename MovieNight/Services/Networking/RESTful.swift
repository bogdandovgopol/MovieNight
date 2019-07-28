//
//  RESTful.swift
//  MovieRoom
//
//  Created by Bogdan Dovgopol on 27/7/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//

import Foundation

let RESTful = _RESTful()

final class _RESTful {
    func request(path: String, method: String, parameters: [String:String]?, headers: [String:String]?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard var components = URLComponents(string: path) else {
            print("Error: Could not create an URL components")
            return
        }
        
        // GET: Query string parameters
        if method == "GET", let parameters = parameters {
            components.queryItems = parameters.map({ (key, value) in
                URLQueryItem(name: key, value: value)
            })
        }
        
        var request = URLRequest(url: components.url!)
        
        // POST/PUT: Request body parameters
        if method == "POST" || method == "PUT" {
            if let parameters = parameters {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                } catch let error {
                    print(error)
                }
            }
        }
        
        request.httpMethod = method
        
        //HEADERS
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        //TASK
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
        
    }
}
