//
//  TICollectionViewController.swift
//  TheIn
//
//  Created by Yehor Shapanov on 10/21/19.
//  Copyright © 2019 Yehor Shapanov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, AlertDisplayer {
    
    let searchController = UISearchController(searchResultsController: nil)
    private var viewModel: PhotosViewModel!
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.prefetchDataSource = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Images"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        indicatorView.color = .green
        indicatorView.startAnimating()
        
        collectionView.isHidden = true
        
        let request = PhotosRequest.new()
        viewModel = PhotosViewModel(request: request, delegate: self)
        
        viewModel.fetchPhotos()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if distance < 200 {
            viewModel.loadMoreData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        let photoDetails = viewModel.photo(at: indexPath.row).thumbnailRecord
        
        switch (photoDetails.state) {
            
            //        case .failed:
            //          indicator.stopAnimating()
        //          cell.textLabel?.text = "Failed to load"
            case .new:
                startOperations(for: photoDetails, at: indexPath)
                
            default:
                cell.configure(with: photoDetails)
        }
        return cell
    }
    
    func startOperations(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        switch (photoRecord.state) {
        case .new:
            startDownload(for: photoRecord, at: indexPath)
        case .downloaded:
            fallthrough
        default:
            NSLog("do nothing")
        }
    }
    
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        guard viewModel.pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        let downloader = ImageDownloader(photoRecord)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.viewModel.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        viewModel.pendingOperations.downloadsInProgress[indexPath] = downloader
        viewModel.pendingOperations.downloadQueue.addOperation(downloader)
    }
}

extension CollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel.fetchPhotos()
        }
    }
}

private extension CollectionViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.currentCount
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathForVisibleItems = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

extension CollectionViewController: PhotosViewModelDelegate {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        indicatorView.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    func onFetchFailed(with reason: String) {
        indicatorView.stopAnimating()
        
        let title = "Warning".localizedString
        let action = UIAlertAction(title: "Retry".localizedString, style: .default) {
            _ in
            self.viewModel.fetchPhotos()
        }
        
        displayAlert(with: title , message: reason, actions: [action])
    }
}

extension CollectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PhotoViewController {
            if let indexPath = collectionView.indexPath(for: sender as! PhotoCollectionViewCell) {
                destination.index = indexPath.row
                destination.viewModel = viewModel
            }
        }
    }
}


extension CollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        print(searchBar.text!)
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 3.0
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

