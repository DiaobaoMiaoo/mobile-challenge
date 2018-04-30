//
//  ViewController.swift
//  CodeChallenge
//
//  Created by Ke MA on 2018-04-29.
//  Copyright © 2018 kemin. All rights reserved.
//

import UIKit

var isDebugging = true

private let reuseIdentifier = "CollectionViewCell"
private let segueIdentifier = "presentPhotoDetailPage"

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let photoManager = PhotoManager()
    var isLoading = false
    var orientationChangedOnDetailView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = collectionView.collectionViewLayout as! CollectionViewLayout
        layout.delegate = self
        layout.numberOfColumns = 2
        layout.cellPadding = 1
        
        isLoading = true
        photoManager.loadPhotos { status, _ in
            self.isLoading = false
            switch status {
            case .success:
                self.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isLoading, orientationChangedOnDetailView {
            orientationChangedOnDetailView = false
            relayoutCollectionView()
        } else {
            print("---- attempted to reload")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier,
            let destination = segue.destination as? DetailViewController,
            let indexPath = sender as? IndexPath {
            
            destination.currentIndexPath = indexPath
            destination.delegate = self
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        relayoutCollectionView()
    }
    
    private func relayoutCollectionView() {
        collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            let layout = CollectionViewLayout()
            layout.delegate = self
            layout.numberOfColumns = 2
            layout.cellPadding = 1
            self.collectionView.setCollectionViewLayout(layout, animated: true)
            self.collectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoManager.numberOfPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.photo = photoManager.photoAtIndexPath(indexPath)
        if indexPath.row == photoManager.numberOfPhotos - 1 {
            loadMorePhotos { _, _ in }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifier, sender: indexPath)
    }
}

extension ViewController: LayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        return photoManager.heightForPhotoAtIndexPath(indexPath, withWidth: width)
    }
}

extension ViewController: DetailViewDelegate {
    
    func indexPathsForPhotos(_ photos: [PhotoModel]) -> [IndexPath] {
        return photoManager.indexPathsForPhotos(photos)
    }
    
    func loadMorePhotos(completion: @escaping (ResponseStatus, [PhotoModel]) -> Void) {
        isLoading = true
        photoManager.loadPhotos { status, loadedPhotos in
            self.isLoading = false
            switch status {
            case .success:
                guard loadedPhotos.count > 0 else { return }
                self.collectionView.insertItems(at: self.photoManager.indexPathsForPhotos(loadedPhotos))
            case .failure(let error):
                print(error)
            }
            completion(status, loadedPhotos)
        }
    }
    
    func numberOfPhotos() -> Int {
        return photoManager.numberOfPhotos
    }
    
    func photoAtIndexPath(_ indexPath: IndexPath) -> PhotoModel {
        return photoManager.photoAtIndexPath(indexPath)
    }
    
    func scrollToIndexPath(_ indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    
    func orientationChanged() {
        orientationChangedOnDetailView = true
    }
}
