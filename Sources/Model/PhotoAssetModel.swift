//
//  PhotoAssetModel.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos


public typealias ResultHandlerOfRequestPhoto = (UIImage?, [AnyHashable : Any]?) -> Swift.Void
public typealias ProgressHandlerOfRequestPhotoInCloud = (Double, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Swift.Void


public class PhotoAssetModel {
    public var name: String {
        return self.asset.localIdentifier
    }
    
    public let asset: PHAsset
    
    public var photoSize: CGSize {
        return CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight)
    }
    
    fileprivate var locallyAvailable = false
    
    public var isInCloud: Bool {
        if self.locallyAvailable {
            return false
        }
        
        if let assetResource = PHAssetResource.assetResources(for: asset).first {
            if let locallyAvailable = assetResource.value(forKey: "locallyAvailable") as? Bool {
                self.locallyAvailable = locallyAvailable
                if self.locallyAvailable == false {
                    return true
                }
            }
        }
        return false
    }
    
    public var isDownloadingFromCloud: Bool {
        return self.imageRequestIdInCloud != PHInvalidImageRequestID
    }
    
    fileprivate var imageRequestIdInCloud: PHImageRequestID = PHInvalidImageRequestID
    
    public init(_ asset: PHAsset) {
        self.asset = asset
    }
}

// MARK: - locallyAvailable

extension PhotoAssetModel {
    @discardableResult
    public func requestThumbnail(resultHandler: @escaping ResultHandlerOfRequestPhoto) -> PHImageRequestID {
        return self.requestAvailableSizeImageInCloud(resultHandler: resultHandler)
    }
    
    @discardableResult
    public func requestScreenSizeImage(resultHandler: @escaping ResultHandlerOfRequestPhoto) -> PHImageRequestID {
        let targetSize = CGSize(width: UIScreen.main.bounds.width * 4, height: UIScreen.main.bounds.height * 4)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        return self._requestImage(targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: resultHandler)
    }
    
    @discardableResult
    public func requestMaxSizeImage(resultHandler: @escaping ResultHandlerOfRequestPhoto) -> PHImageRequestID {
        let targetSize = PHImageManagerMaximumSize
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        return self._requestImage(targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: resultHandler)
    }
}

// MARK: - iCloud

extension PhotoAssetModel {
    @discardableResult
    public func requestAvailableSizeImageInCloud(resultHandler: @escaping ResultHandlerOfRequestPhoto) -> PHImageRequestID {
        // the max size of photo without downloading from icloud.
        // the most suitable size of thumbnail
        let targetSize = CGSize(width:256, height:256)
        return self._requestImage(targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: resultHandler)
    }
    
    @discardableResult
    public func requestMaxSizeImageInCloud(resultHandler: @escaping ResultHandlerOfRequestPhoto, progressHandler: @escaping ProgressHandlerOfRequestPhotoInCloud) -> PHImageRequestID {
        let targetSize = PHImageManagerMaximumSize
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.progressHandler = progressHandler
        self.imageRequestIdInCloud = self._requestImage(targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { [weak self] (image, info) in
            if let image = image {
                if image.size.width > 256 && image.size.height > 256 {
                    self?.locallyAvailable = true
                    resultHandler(image, info)
                }
            }
        })
        return self.imageRequestIdInCloud
    }
    
    public func cancelImageRequestInCloud() {
        if self.imageRequestIdInCloud != PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.imageRequestIdInCloud)
            self.imageRequestIdInCloud = PHInvalidImageRequestID
        }
    }
}

extension PhotoAssetModel {
    @discardableResult
    fileprivate func _requestImage(targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, resultHandler: @escaping ResultHandlerOfRequestPhoto) -> PHImageRequestID {
        return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
}

extension PhotoAssetModel: CustomStringConvertible {
    public var description: String {
        return self.name
    }
}
