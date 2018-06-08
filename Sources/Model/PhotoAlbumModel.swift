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
        return self.assetCollection.localizedTitle!
    }
    
    public let assetCollection: PHAssetCollection
    public var fetchResult: PHFetchResult<PHAsset>
    
    public var photoAssets = [PhotoAssetModel]()
    
    public var lastPhotoAsset: PhotoAssetModel? {
        return self.photoAssets.last
    }
    
    public weak var delegate: PhotoAlbumDelegate?
    
    public init(_ assetCollection: PHAssetCollection) {
        self.assetCollection = assetCollection
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType=1")
        self.fetchResult = PHAsset.fetchAssets(in: self.assetCollection, options: options)
        
        self.reloadPhotoAssets()
    }
    
    public func changeWithDetails(_ changeDetails: PHFetchResultChangeDetails<PHAsset>) {
        self.fetchResult = changeDetails.fetchResultAfterChanges
        
        self.reloadPhotoAssets()
        
        self.delegate?.PhotoAlbumChangeWithDetails(changeDetails)
    }
    
    fileprivate func reloadPhotoAssets() {
        self.photoAssets.removeAll()
        self.fetchResult.enumerateObjects( { (asset, idx, stop) in
            let photoAssetModel = PhotoAssetModel.init(asset)
            self.photoAssets.append(photoAssetModel)
        })
    }
}

extension PhotoAlbumModel: CustomStringConvertible {
    public var description: String {
        return self.name
    }
}
