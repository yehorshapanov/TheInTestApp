//
//  PhotoCollectionViewCell.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/22/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configure(with: .none)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        indicatorView.color = .red
    }
    
    func configure(with photoRecord: PhotoRecord?) {
        if let photo = photoRecord?.image {
            imageView.image = photo
            indicatorView.stopAnimating()
        } else {
            imageView.image = nil
            indicatorView.startAnimating()
        }
    }
}

