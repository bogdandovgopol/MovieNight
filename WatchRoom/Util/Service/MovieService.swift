//
//  MovieService.swift
//  WatchRoom
//
//  Created by Bogdan on 21/8/20.
//

import Foundation
import FirebaseCrashlytics

enum MError: String, Error {
    case networkingError = "Couldn't fetch movies"
    case errorDecoding = "There was an error while decoding JSON"
}

struct MovieService {
    
    static let shared = MovieService()
    
    func getMovies(path: String, parameters: [String: String], completion: @escaping (Result<MovieFeed, MError>) -> Void ) {
        RESTful.request(path: path, method: .get, parameters: parameters, headers: nil) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completion(.failure(.networkingError))
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do{
                    let feed = try jsonDecoder.decode(MovieFeed.self, from: data)
                    
                    completion(.success(feed))
                } catch (let error) {
                    debugPrint(error.localizedDescription)
                    completion(.failure(.errorDecoding))
                }
            }
        }
    }
    
    func getMovie(path: String, parameters: [String: String], completion: @escaping (Result<MovieDetail, MError>) -> Void ) {
        RESTful.request(path: path, method: .get, parameters: parameters, headers: nil) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completion(.failure(.networkingError))
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do{
                    let movie = try jsonDecoder.decode(MovieDetail.self, from: data)
                    
                    completion(.success(movie))
                } catch (let error) {
                    debugPrint(error.localizedDescription)
                    completion(.failure(.errorDecoding))
                }
            }
        }
    }
}
