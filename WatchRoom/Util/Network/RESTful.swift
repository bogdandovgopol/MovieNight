//
//  RESTful.swift
//
//  Created by Bogdan Dovgopol on 27/7/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//
import Foundation

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: Networking
let RESTful = _RESTful()
final class _RESTful {
    func request(path: String, method: RequestMethod, parameters: [String:Any]?, headers: [String:String]?, completion: @escaping (Result<Data, WRError>) -> Void) {
        
        guard var components = URLComponents(string: path) else {
            completion(.failure(.invalidUrl))
            return
        }
                
        // GET: Query string parameters
        if method == .get, let parameters = parameters {
            components.queryItems = parameters.map({ (key, value) in
                URLQueryItem(name: key, value: "\(value)")
            })
        }
                
        var request = URLRequest(url: components.url!)
        
        // POST/PUT: Request body parameters
        if method == .post || method == .put || method == .delete {
            if let parameters = parameters {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                } catch {
                    completion(.failure(.invalidJson))
                }
            }
        }
        request.httpMethod = method.rawValue
        
        //HEADERS
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        //TASK
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if let _ = error {
                completion(.failure(.unableToComplete))
            }
            
//            debugPrint(String(data: request.httpBody ?? Data(), encoding: String.Encoding.utf8))
//            print(String(data: data!, encoding: String.Encoding.utf8))
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
}
