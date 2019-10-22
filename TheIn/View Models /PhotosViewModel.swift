//
//  PhotosViewModel.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/21/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//
import Foundation

protocol PhotosViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
}

final class PhotosViewModel {
    private weak var delegate: PhotosViewModelDelegate?
    
    private var photos: [Photo] = []
    let pendingOperations = PendingOperations()
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    
    let client = UnsplashClient()
    let request: PhotosRequest
    
    init(request: PhotosRequest, delegate: PhotosViewModelDelegate) {
        self.request = request
        self.delegate = delegate
    }
    
    var totalCount: Int {
        return total
    }
    
    var currentCount: Int {
        return photos.count
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    func Print() {
        for a in photos {
            print(a.id)
        }
    }
    
    func fetchPhotos() {
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        client.fetchPhotos(with: request, page: currentPage) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.delegate?.onFetchFailed(with: error.reason)
                }
                
            case .success(let response):
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    
                    self.total += response.count
                    self.photos.append(contentsOf: response)
                    self.delegate?.onFetchCompleted(with: .none)
                    
                }
            }
        }
    }
    func loadMoreData() {
        
        self.currentPage += 1
        self.fetchPhotos()
        
    }
    
    private func calculateIndexPathsToReload(from newPhotos: [Photo]) -> [IndexPath] {
        let startIndex = photos.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
