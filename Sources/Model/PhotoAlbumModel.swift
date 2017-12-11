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
    var name: String {
        return assetCollection.localizedTitle!
    }
    
    var assetCollection: PHAssetCollection!
    var fetchResult: PHFetchResult<PHAsset>!
    
    var photosCount: Int {
        return fetchResult.count
    }
    
    var thumbnail: PHAsset {
        return fetchResult.lastObject!
    }
    
    var isCameraRoll: Bool!
}

extension PhotoAlbumModel: CustomStringConvertible {
    public var description: String {
        return name
    }
}
