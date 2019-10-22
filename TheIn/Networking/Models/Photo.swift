//
//  Photo.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/21/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//
import UIKit
import Foundation

struct Photo: Decodable {
    let id: String
    let rawImage: String
    let thumbnail: String
    let thumbnailRecord: PhotoRecord
    let rawImageRecord: PhotoRecord
    
    enum CodingKeys: String, CodingKey {
        case id
        case urls
        enum URLKeys: String, CodingKey {
            case raw
            case thumb
        }
    }
    
    init(_ id: String, rawImage: String, thumbnail: String) {
        self.id = id
        self.rawImage = rawImage
        self.thumbnail = thumbnail
        self.thumbnailRecord = PhotoRecord(url: URL(string: thumbnail)!)
        self.rawImageRecord = PhotoRecord(url: URL(string: rawImage)!)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let urlsContainer = try container.nestedContainer(keyedBy: CodingKeys.URLKeys.self, forKey: .urls)
        let raw = try urlsContainer.decode(String.self, forKey: .raw)
        let thumb = try urlsContainer.decode(String.self, forKey: .thumb)
        self.init(id, rawImage: raw, thumbnail: thumb)
    }
}

enum PhotoRecordState {
    case new, downloaded, failed
}

class PhotoRecord {
    let url: URL
    var state = PhotoRecordState.new
    var image: UIImage?
    
    init(url:URL) {
        self.url = url
    }
}
