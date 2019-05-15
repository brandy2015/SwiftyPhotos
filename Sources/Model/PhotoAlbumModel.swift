//
//  PhotoAlbumModel.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos


public protocol PhotoAlbumDelegate: class {
    func PhotoAlbumChangeWithDetails(_ changeDetails: PHFetchResultChangeDetails<PHAsset>)
}


public class PhotoAlbumModel {
    public var name: String {
        if let localizedTitle = assetCollection.localizedTitle {
            return localizedTitle
        }
        return ""
    }
    
    public let assetCollection: PHAssetCollection
    public var fetchResult: PHFetchResult<PHAsset>
    
    public var photoAssets = [PhotoAssetModel]()
    
    public var lastPhotoAsset: PhotoAssetModel? {
        return photoAssets.last
    }
    
    public weak var delegate: PhotoAlbumDelegate?
    
    public init(_ assetCollection: PHAssetCollection) {
        self.assetCollection = assetCollection
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType=\(PHAssetMediaType.image.rawValue)")
        self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        
        reloadPhotoAssets()
    }
    
    public func changeWithDetails(_ changeDetails: PHFetchResultChangeDetails<PHAsset>) {
        fetchResult = changeDetails.fetchResultAfterChanges
        
        reloadPhotoAssets()
        
        delegate?.PhotoAlbumChangeWithDetails(changeDetails)
    }
    
    fileprivate func reloadPhotoAssets() {
        photoAssets.removeAll()
        fetchResult.enumerateObjects( { (asset, idx, stop) in
            let photoAssetModel = PhotoAssetModel(asset)
            self.photoAssets.append(photoAssetModel)
        })
    }
}

// MARK: - CustomStringConvertible
extension PhotoAlbumModel: CustomStringConvertible {
    public var description: String {
        return name
    }
}
