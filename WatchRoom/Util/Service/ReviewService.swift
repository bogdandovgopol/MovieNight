//
//  ReviewService.swift
//  WatchRoom
//
//  Created by Bogdan on 5/9/20.
//

import Foundation

struct ReviewService {
    static let shared = ReviewService()
    private init() {}
    
    func getMovieReviews(movieId: Int, parameters: [String: String], completion: @escaping (Result<Credits, MError>) -> Void ) {
        let path = "\(TMDB_API.BaseURL)/movie/\(movieId)/reviews"
        RESTful.request(path: path, method: .get, parameters: parameters, headers: nil) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completion(.failure(.networkingError))
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do{
                    let credits = try jsonDecoder.decode(Credits.self, from: data)
                    
                    completion(.success(credits))
                } catch (let error) {
                    debugPrint(error.localizedDescription)
                    completion(.failure(.errorDecoding))
                }
            }
        }
    }
}
