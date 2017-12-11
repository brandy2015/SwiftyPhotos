//
//  PhotoAssetModel.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos

public class PhotoAssetModel {

    var name: String {
        get {
            return asset.localIdentifier
        }
    }
    
    var asset: PHAsset!
}

extension PhotoAssetModel: CustomStringConvertible {
    public var description: String {
        return name
    }
}
