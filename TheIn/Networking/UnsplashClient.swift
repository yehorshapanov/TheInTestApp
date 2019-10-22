//
//  MonoSnapClient.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/21/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//

import Foundation

class UnsplashClient {
    let clientId = "4c9fbfbbd92c17a2e95081cec370b4511659666240eb4db9416c40c641ee843b"
    
    private lazy var baseURL: URL = {
        return URL(string: "https://api.unsplash.com/")!
    }()
    
    private lazy var authorizationHeader: String = {
        return "Client-ID \(clientId)"
    }()
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchPhotos(with request: PhotosRequest, page: Int, completion: @escaping (Result<[Photo], DataResponseError>) -> Void) {
        
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
        urlRequest.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        let parameters = ["page": "\(page)"].merging(request.parameters, uniquingKeysWith: +)
        let encodedURLRequest = urlRequest.encode(with: parameters)
        
        session.dataTask(with: encodedURLRequest, completionHandler: { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
                else {
                    completion(Result.failure(DataResponseError.network))
                    return
            }
            guard let decodedResponse = try? JSONDecoder().decode([Photo].self, from: data) else {
                completion(Result.failure(DataResponseError.decoding))
                return
            }
            completion(Result.success(decodedResponse))
        }).resume()
    }
}


