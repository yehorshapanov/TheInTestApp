//
//  HTTPURLResponse.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/21/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    var hasSuccessStatusCode: Bool {
        return 200...299 ~= statusCode
    }
}
