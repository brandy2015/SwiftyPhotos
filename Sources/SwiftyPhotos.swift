//
//  SwiftyPhotos.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos


public typealias ResultHandlerOfPhotoOperation = (Bool, Error?) -> Void
public typealias ResultHandlerOfPhotoAuthrization = (Bool) -> Void


fileprivate let AlbumsOfIOS = ["All Photos", "Camera Roll", "Selfies", "Screenshots", "Favorites", "Panoramas", "Recently Added"]
fileprivate let AlbumsOfAllPhotos = ["All Photos", "Camera Roll"]


public class SwiftyPhotos {
    public var isPhotoAuthorized = false
    
    public var allPhotoAlbums = [PhotoAlbumModel]()
    public var allPhotoAssets: [PhotoAssetModel] {
        for (_, photoAlbum) in self.allPhotoAlbums.enumerated() {
            if AlbumsOfAllPhotos.contains(photoAlbum.name) {
                return photoAlbum.photoAssets
            }
        }
        return [PhotoAssetModel]()
    }
    
    private static let sharedInstance = SwiftyPhotos()
    public class var shared: SwiftyPhotos {
        return sharedInstance
    }
}

extension SwiftyPhotos {
    public func reloadAll(resultHandler: @escaping ResultHandlerOfPhotoAuthrization) {
        self.requestAuthorization { (isPhotoAuthorized) in
            if isPhotoAuthorized {
                self._reloadAll()
            }
            resultHandler(isPhotoAuthorized)
        }
    }
    
    private func requestAuthorization(resultHandler: @escaping ResultHandlerOfPhotoAuthrization) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                if authorizationStatus == .authorized {
                    resultHandler(true)
                } else {
                    resultHandler(false)
                }
            }
            break
        case .restricted, .denied:
            print("authorizationStatus denied")
            resultHandler(false)
            break
        case .authorized:
            resultHandler(true)
        }
    }
    
    private func _reloadAll() {
        let handleAssetCollection = { (assetCollection: PHAssetCollection) in
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType=1")
            
            let photoAlbum = PhotoAlbumModel.init(assetCollection)
            if photoAlbum.photoAssets.count > 0 {
                if AlbumsOfAllPhotos.contains(photoAlbum.name) {
                    self.allPhotoAlbums.insert(photoAlbum, at: 0)
                } else {
                    self.allPhotoAlbums.append(photoAlbum)
                }
            }
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects(_:) { (assetCollection, idx, stop) in
            if let albumName = assetCollection.localizedTitle {
                if AlbumsOfIOS.contains(albumName) {
                    handleAssetCollection(assetCollection)
                }
            }
        }
        
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        albums.enumerateObjects(_:) { (assetCollection, idx, stop) in
            handleAssetCollection(assetCollection)
        }
    }
}

// MARK: - Album

extension SwiftyPhotos {
    public func photoAlbumWithName(_ albumName: String) -> PhotoAlbumModel? {
        for (_, photoAlbum) in self.allPhotoAlbums.enumerated() {
            if photoAlbum.name == albumName {
                return photoAlbum
            }
        }
        return nil
    }
    
    public func createAlbum(_ albumName: String) -> Bool {
        if let _ = self.photoAlbumWithName(albumName) {
            print("already existing album")
            return false
        }
        
        var isAlbumCreated = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) { (isSuccess, error) in
            if isSuccess == true {
                print("success to create album : \(albumName)")
                isAlbumCreated = true
            } else {
                print("fail to create album : \(albumName). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return isAlbumCreated
    }
}

// MARK: - Photo

extension SwiftyPhotos {
    
    public func saveImage(_ image: UIImage, into albumName: String, withLocation: Bool, resultHandler: @escaping ResultHandlerOfPhotoOperation) -> Bool {
        guard let photoAlbum = self.photoAlbumWithName(albumName) else {
            return false
        }
        
        var isImageSaved = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        PHPhotoLibrary.shared().performChanges({
            
            // 请求创建一个asset
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if withLocation == true {
//                assetChangeRequest.location = LocationManager.shared.currentCsLocation?.location
            }
            
            //为Asset创建一个占位符，放到相册编辑请求中
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            
            // 请求改变相册
            let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: photoAlbum.assetCollection)
            let fastEnumerate: NSArray = [assetPlaceholder!]
            assetCollectionChangeRequest?.addAssets(fastEnumerate)
            
        }) { (isSuccess, error) in
            if isSuccess == true {
                print("success to save image to album : \(albumName)")
                isImageSaved = true
            } else {
                print("fail to save image to album : \(albumName). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return isImageSaved
    }
    
    public func deleteAsset(_ photoAsset: PhotoAssetModel, resultHandler: @escaping ResultHandlerOfPhotoOperation) -> Bool {
        var isAssetDeleted = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        PHPhotoLibrary.shared().performChanges({
            let fastEnumerate: NSArray = [photoAsset.asset]
            PHAssetChangeRequest.deleteAssets(fastEnumerate)
        }) { (isSuccess, error) in
            if isSuccess == true {
                print("success to delete asset : \(photoAsset.name)")
                isAssetDeleted = true
            } else {
                print("fail to delete asset : \(photoAsset.name). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return isAssetDeleted
    }
}












