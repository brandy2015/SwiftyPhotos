//
//  PhotoAlbumModel.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos

public class PhotoAlbumModel {
    public var name: String {
        return self.assetCollection.localizedTitle!
    }
    
    public let assetCollection: PHAssetCollection
    public let fetchResult: PHFetchResult<PHAsset>
    
    public let photoAssets: [PhotoAssetModel]
    
    public var lastPhotoAsset: PhotoAssetModel? {
        return self.photoAssets.last
    }
    
    public init(_ assetCollection: PHAssetCollection) {
        self.assetCollection = assetCollection
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType=1")
        self.fetchResult = PHAsset.fetchAssets(in: self.assetCollection, options: options)
        
        var array = [PhotoAssetModel]()
        self.fetchResult.enumerateObjects { (asset, idx, stop) in
            let photoAssetModel = PhotoAssetModel.init(asset)
            array.append(photoAssetModel)
        }
        self.photoAssets = array
    }
}

extension PhotoAlbumModel: CustomStringConvertible {
    public var description: String {
        return self.name
    }
}
