//
//  PhotoViewController.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/22/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//

import Foundation
import UIKit
class PhotoViewController: UIViewController {
    var viewModel: PhotosViewModel?
    var index: Int = 0
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.color = .gray
        
        let photo = viewModel?.photo(at: index)
        
        if let imageRecord = photo?.rawImageRecord {
            switch imageRecord.state {
            case .new:
                startDownload(for: imageRecord)
            default:
                indicatorView.stopAnimating()
                imageView.image = imageRecord.image!
            }
        }
    }
    
    func startDownload(for photoRecord: PhotoRecord) {
        let downloader = ImageDownloader(photoRecord)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.imageView.image = photoRecord.image!
            }
        }
        viewModel?.pendingOperations.downloadQueue.addOperation(downloader)
    }
}
