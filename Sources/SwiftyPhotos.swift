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


public class SwiftyPhotos: NSObject {
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
        PHPhotoLibrary.shared().register(sharedInstance)
        return sharedInstance
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

public extension SwiftyPhotos {
    public func reloadAll(resultHandler: @escaping ResultHandlerOfPhotoAuthrization) {
        self.requestAuthorization { (isPhotoAuthorized) in
            if isPhotoAuthorized {
                self._reloadAll()
            }
            resultHandler(isPhotoAuthorized)
        }
    }
    
    public func requestAuthorization(resultHandler: @escaping ResultHandlerOfPhotoAuthrization) {
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
    
    fileprivate func _reloadAll() {
        let handleAssetCollection = { (assetCollection: PHAssetCollection) in
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType=1")
            
            let photoAlbum = PhotoAlbumModel.init(assetCollection)
            if AlbumsOfAllPhotos.contains(photoAlbum.name) {
                self.allPhotoAlbums.insert(photoAlbum, at: 0)
            } else {
                self.allPhotoAlbums.append(photoAlbum)
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

public extension SwiftyPhotos {
    public func photoAlbumWithName(_ albumName: String) -> PhotoAlbumModel? {
        for (_, photoAlbum) in self.allPhotoAlbums.enumerated() {
            if photoAlbum.name == albumName {
                return photoAlbum
            }
        }
        return nil
    }
    
    @discardableResult
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
                print("SwiftyPhotos : success to create album : \(albumName)")
                isAlbumCreated = true
            } else {
                print("SwiftyPhotos : fail to create album : \(albumName). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        
        self.allPhotoAlbums.removeAll()
        self._reloadAll()
        return isAlbumCreated
    }
}

// MARK: - Photo

public extension SwiftyPhotos {
    public func saveImage(_ image: UIImage, intoAlbum albumName: String, withLocation location: CLLocation?, resultHandler: @escaping ResultHandlerOfPhotoOperation) -> Bool {
        self.createAlbum(albumName)
        
        guard let photoAlbum = self.photoAlbumWithName(albumName) else {
            return false
        }
        
        var isImageSaved = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        PHPhotoLibrary.shared().performChanges({
            
            // create an asset change request
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let location = location {
                assetChangeRequest.location = location
            }
            
            // create a placeholder for asset, and add into assetCollectionChangeRequest
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            
            // create an assetCollection change request
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
        
        resultHandler(isImageSaved, nil)
        
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
        
        resultHandler(isAssetDeleted, nil)
        
        return isAssetDeleted
    }
}

extension SwiftyPhotos: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        for (_, photoAlbum) in self.allPhotoAlbums.enumerated() {
            if let changeDetails = changeInstance.changeDetails(for: photoAlbum.fetchResult) {
                photoAlbum.changeWithDetails(changeDetails)
            }
        }
    }
}

