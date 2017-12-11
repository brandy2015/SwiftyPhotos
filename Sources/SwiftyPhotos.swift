//
//  SwiftyPhotos.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos

public class SwiftyPhotos {
    
    public var isAllPhotosExisting = false
    
    public var allAlbums   = Array<PhotoAlbumModel>()
    public var allAssets: Array<PhotoAssetModel> {
        get {
            var assets = Array<PhotoAssetModel>()
            
            var assetCollection: PHAssetCollection?
            let cameraRollResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            cameraRollResult.enumerateObjects(_:) { (collection, idx, stop) in
                if collection.assetCollectionSubtype != .albumCloudShared ||
                    collection.assetCollectionSubtype != .smartAlbumPanoramas {
                    
                    if let title = collection.localizedTitle {
                        let allAssetsTitle = self.isAllPhotosExisting ? "All Photos" : "Camera Roll"
                        if title == allAssetsTitle {
                            assetCollection = collection
                            stop.initialize(to: true)
                        }
                    }
                }
            }
            
            if let assetCollection = assetCollection {
                let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: assetCollection, options: nil)
                fetchResult.enumerateObjects(_:) { (asset, idx, stop) in
                    let photoAssetModel = PhotoAssetModel()
                    photoAssetModel.asset = asset
                    
                    assets.append(photoAssetModel)
                }
            }
            
            return assets
        }
        set {
        
        }
    }
    
    private static let sharedInstance = SwiftyPhotos()
    public class var shared: SwiftyPhotos {
        if sharedInstance.allAlbums.count == 0 {
            sharedInstance.syncAlbums()
        }
        return sharedInstance
    }
    
    public func reset() {
        allAlbums.removeAll()
        allAssets.removeAll()
    }
}

extension SwiftyPhotos {
    func syncAlbums() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key:"endDate", ascending: false)]
        options.predicate = NSPredicate(format: "estimatedAssetCount>0")
        
        let cameraRollResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        
        let handleAssetCollection = { (assetCollection: PHAssetCollection, isCameraRoll: Bool) in
            
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType=1")
            
            let photos = PHAsset.fetchAssets(in: assetCollection, options: options)
            if photos.count > 0 {
                let albumModel              = PhotoAlbumModel()
                albumModel.assetCollection  = assetCollection
                albumModel.fetchResult      = photos
                albumModel.isCameraRoll     = isCameraRoll
                
                if assetCollection.assetCollectionType == .smartAlbum &&
                    assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    var isExisting = false
                    for album: PhotoAlbumModel in self.allAlbums {
                        if album.name == albumModel.name {
                            isExisting = true
                        }
                    }
                    if !isExisting {
                        self.allAlbums.insert(albumModel, at: 0)
                    }
                } else {
                    var isExisting = false
                    for album: PhotoAlbumModel in self.allAlbums {
                        if album.name == albumModel.name {
                            isExisting = true
                        }
                    }
                    if !isExisting {
                        self.allAlbums.append(albumModel)
                    }
                }
            }
        }
        
        cameraRollResult.enumerateObjects(_:) { (assetCollection, idx, stop) in
            if assetCollection.assetCollectionSubtype != .albumCloudShared ||
                assetCollection.assetCollectionSubtype != .smartAlbumPanoramas {
                handleAssetCollection(assetCollection, true)
            }
        }
        userAlbums.enumerateObjects(_:) { (assetCollection, idx, stop) in
            if assetCollection.assetCollectionSubtype != .albumCloudShared ||
                assetCollection.assetCollectionSubtype != .smartAlbumPanoramas {
                handleAssetCollection(assetCollection, false)
            }
        }
        
        // 解决部分机型没有All Photos，而是Camera Roll的问题
        for albumModel in allAlbums {
            if albumModel.name == "All Photos" {
                isAllPhotosExisting = true
                break
            } else {
                isAllPhotosExisting = false
            }
        }
    }
}

// MARK: - 操作相册
extension SwiftyPhotos {
    func isAlbumExisting(_ albumName: String) -> Bool {
        var isAlbumExisting = false
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        topLevelUserCollections.enumerateObjects(_:) { (assetCollection, idx, stop) in
            if assetCollection.localizedTitle == albumName {
                stop.initialize(to: true)
                isAlbumExisting = true
            }
        }
        
        return isAlbumExisting
    }
    
    func createAlbum(_ albumName: String) -> Bool {
        var isCreationSuccess = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) { (success, error) in
            if success == true {
                isCreationSuccess = true
                print("success to create album : \(albumName)")
            } else {
                print("failed to create album : \(albumName). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return isCreationSuccess
    }
    
    func albumByName(_ albumName: String) -> PhotoAlbumModel? {
        for albumModel: PhotoAlbumModel in allAlbums {
            if albumModel.name == albumName {
                return albumModel
            }
        }
        
        return nil
    }
    
    func assetCollectionByName(_ collectionName: String) -> PHAssetCollection? {
        var album: PHAssetCollection?
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        topLevelUserCollections.enumerateObjects(_:) { (assetCollection, idx, stop) in
            if assetCollection.localizedTitle == collectionName {
                stop.initialize(to: true)
                album = assetCollection as? PHAssetCollection
            }
        }
        return album
    }
    
    func photoAssetsByAlbumModel(_ albumModel: PhotoAlbumModel) -> Array<PhotoAssetModel> {
        if albumModel.name == allAlbums.first?.name {
            return allAssets
        }
        
        var photoAssets = Array<PhotoAssetModel>()
        
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: albumModel.assetCollection, options: nil)
        fetchResult.enumerateObjects({ (asset, idx, stop) in
            let photoAssetModel = PhotoAssetModel()
            photoAssetModel.asset = asset
            
            photoAssets.append(photoAssetModel)
        })
        
        return photoAssets
    }
}

// MARK: - 请求照片
extension SwiftyPhotos {
    
    // 缩略图
    @discardableResult
    func requestThumbnailForAsset(asset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        // 仅request指定尺寸image，不需要更小的缩略图
        options.isSynchronous = true
        return requestImageForAsset(asset: asset, targetSize: CGSize(width:256, height:256), contentMode: .aspectFit, options: options, resultHandler: resultHandler)
    }
    
    // 全尺寸
    @discardableResult
    func requestFullSizeImageForAsset(asset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID {
        return requestImageForAsset(asset: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: resultHandler)
    }
    
    @discardableResult
    func requestFullSizeImageForAssetLocalIdentifier(_ localIdentifier: String, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        if assets.count == 0 { return PHInvalidImageRequestID }
        guard let asset = assets.firstObject else { return PHInvalidImageRequestID }
        return requestFullSizeImageForAsset(asset: asset, resultHandler: resultHandler)
    }
    
    // 屏幕尺寸
    @discardableResult
    func requestScreenSizeImageForAsset(asset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID? {
        let size = CGSize(width: UIScreen.main.bounds.width * 4,
                          height: UIScreen.main.bounds.height * 4)
        
        let options = PHImageRequestOptions()
        // 仅request指定尺寸image，不需要更小的缩略图
        options.isSynchronous = true
        return requestImageForAsset(asset: asset, targetSize: size, contentMode: .aspectFit, options: options, resultHandler: resultHandler)
    }
    
    @discardableResult
    func requestScreenSizeImageForAssetLocalIdentifier(_ localIdentifier: String, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        if assets.count == 0 { return PHInvalidImageRequestID }
        guard let asset = assets.firstObject else { return PHInvalidImageRequestID }
        return requestScreenSizeImageForAsset(asset: asset, resultHandler: resultHandler)
    }
    
    @discardableResult
    func requestThumbnailForAssetLocalIdentifier(_ localIdentifier: String, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        if assets.count == 0 { return PHInvalidImageRequestID }
        guard let asset = assets.firstObject else { return PHInvalidImageRequestID }
        return requestThumbnailForAsset(asset: asset, resultHandler: resultHandler)
    }
    
    @discardableResult
    func requestImageForAsset(asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID {
        return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    
    @discardableResult
    func requestImageForAssetLocalIdentifier(_ localIdentifier: String, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        if assets.count == 0 { return PHInvalidImageRequestID }
        guard let asset = assets.firstObject else { return PHInvalidImageRequestID }
        return requestImageForAsset(asset: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: resultHandler)
    }
}

// MARK: - 保存/删除照片
extension SwiftyPhotos {
    
    func saveImage(image: UIImage, albumName: String, withLocation: Bool) -> Bool {
        var isSaveSuccess = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        // 获取指定相册
        guard let assetCollection = assetCollectionByName(albumName) else {
            return false
        }
        
        PHPhotoLibrary.shared().performChanges({
            
            // 请求创建一个asset
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if withLocation == true {
//                assetChangeRequest.location = LocationManager.shared.currentCsLocation?.location
            }
            
            //为Asset创建一个占位符，放到相册编辑请求中
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            
            // 请求改变相册
            let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
            let fastEnumerate: NSArray = [assetPlaceholder!]
            assetCollectionChangeRequest?.addAssets(fastEnumerate)
            
        }) { (success, error) in
            if success == true {
                isSaveSuccess = true
                print("success to save image to album : \(albumName)")
            } else {
                isSaveSuccess = false
                print("failed to save image to album : \(albumName). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return isSaveSuccess
    }
    
    func deleteAsset(_ asset: PHAsset) {
        PHPhotoLibrary.shared().performChanges({
            let fastEnumerate: NSArray = [asset]
            PHAssetChangeRequest.deleteAssets(fastEnumerate)
        }, completionHandler: nil)
    }
}












