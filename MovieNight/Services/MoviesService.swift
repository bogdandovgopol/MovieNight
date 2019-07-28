//
//  MoviesService.swift
//  MovieRoom
//
//  Created by Bogdan Dovgopol on 27/7/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//

import Foundation
import UIKit

let MovieService = _MovieService()

final class _MovieService {
    func getMovies(url: String, completion: @escaping ([Movie]?, Error?) -> Void) {
        RESTful.request(
            path: url, method: "GET",
            parameters: ["api_key" : TMDB.API_KEY, "region" : "US"],
            headers: nil) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, "Did not receive data from API" as! Error)
                    print("Error: Did not receive data from API")
                    return
                }
                
                do {
                    let rootJSONObject = try JSONSerialization.jsonObject(with: data)
                    
                    guard let rootDictionary = rootJSONObject as? [String:Any],
                        let jsonArray = rootDictionary["results"] as? [[String:Any]] else {
                        completion(nil, "Error in converting JSON to string" as! Error)
                            return
                    }
                    
                    var movies = [Movie]()
                    for json in jsonArray {
                        if var movie = Movie(json: json) {
                            movies.append(movie)
                        }
                    }
                    
                    completion(movies, nil)
                } catch {
                    completion(nil, "Error in converting data to JSON" as! Error)
                }
        }
    }
    
    func getUIImageFromUrl(imageURL: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let session = URLSession.shared
        if let url = URL(string: imageURL) {
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(nil, "Error calling GET on \(imageURL): \(error)" as! Error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, "Error: Did not receive data" as! Error)
                    return
                }
                
                if let image = UIImage(data: data) {
                    completion(image, nil)
                }
            }
            task.resume()
        }
    }
}
