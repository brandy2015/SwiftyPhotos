//
//  PhotoAssetsView.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 24/05/2018.
//  Copyright © 2018 com.icetime. All rights reserved.
//

import UIKit


protocol PhotoAssetsViewDelegate: class {
    func PhotoAssetsViewDidSelectPhoto(_ photoAsset: PhotoAssetModel)
}


class PhotoAssetsView: UIView {
    
    public weak var delegate: PhotoAssetsViewDelegate?
    
    // album
    fileprivate var photoAlbum: PhotoAlbumModel
    
    // cell count of one line
    private let cellCountOfLine: Int
    // offset between cells
    private let cellOffset: CGFloat
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = self.cellOffset
        layout.minimumLineSpacing = self.cellOffset
        
        let itemWidth = (self.frame.width - self.cellOffset * CGFloat(self.cellCountOfLine - 1)) / CGFloat(self.cellCountOfLine)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let cv: UICollectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        
        cv.register(PhotoAssetsCell.classForCoder(), forCellWithReuseIdentifier: "PhotoAssetsCell")
        
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    
    public init(frame: CGRect, photoAlbum: PhotoAlbumModel, cellCountOfLine: Int, cellOffset: CGFloat) {
        self.photoAlbum = photoAlbum
        self.cellCountOfLine = cellCountOfLine
        self.cellOffset = cellOffset
        
        super.init(frame: frame)
        
        self.addSubview(self.collectionView)
    }
    
    public func reload(_ photoAlbum: PhotoAlbumModel) {
        self.photoAlbum = photoAlbum
        self.collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoAssetsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoAlbum.photoAssets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAssetsCell", for: indexPath) as! PhotoAssetsCell
        
        cell.photoAsset = self.photoAlbum.photoAssets[indexPath.item]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoAssetsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = self.delegate {
            let photoAsset = self.photoAlbum.photoAssets[indexPath.item]
            delegate.PhotoAssetsViewDidSelectPhoto(photoAsset)
        }
    }
}
