//
//  UsersRequest.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/21/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//

import Foundation

struct PhotosRequest {
    var path: String {
        return "photos"
    }
    
    let parameters: Parameters
    private init(parameters: Parameters) {
        self.parameters = parameters
    }
}

// Factory
extension PhotosRequest {
  static func new() -> PhotosRequest {
    let defaultParameters =                 // here we'd add additional parameters like "order", "sort", etc.
        ["order_by": "latest", "per_page": "30"]
    return PhotosRequest(parameters: defaultParameters)
  }
}
