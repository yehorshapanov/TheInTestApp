//
//  PhotoOperation.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/22/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//

import Foundation
import UIKit

class PendingOperations {
  lazy var downloadsInProgress: [IndexPath: Operation] = [:]
  lazy var downloadQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "Download queue"
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
}

class ImageDownloader: Operation {
  let photoRecord: PhotoRecord
  
  init(_ photoRecord: PhotoRecord) {
    self.photoRecord = photoRecord
  }
  
  override func main() {
    if isCancelled {
      return
    }
    
    guard let imageData = try? Data(contentsOf: photoRecord.url) else { return }
    
    if isCancelled {
      return
    }
    
    if !imageData.isEmpty {
      photoRecord.image = UIImage(data:imageData)
      photoRecord.state = .downloaded
    } else {
      photoRecord.state = .failed
      photoRecord.image = UIImage(named: "Failed")
    }
  }
}
