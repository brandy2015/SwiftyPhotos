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


fileprivate let AlbumsOfIOS = ["Selfies", "Screenshots", "Favorites", "Panoramas", "Recently Added"]


public class SwiftyPhotos: NSObject {
    public var isPhotoAuthorized = false
    
    /// all albums
    public var allAlbums = [PhotoAlbumModel]()
    
    /// Album for All Photos
    public var allPhotosAlbum: PhotoAlbumModel? {
        return allAlbums.first
    }
    /// Photos for All Photos Album
    public var allPhotosAssets: [PhotoAssetModel] {
        if let allPhotosAlbum = allPhotosAlbum {
            return allPhotosAlbum.photoAssets
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

// MARK: - Authrization

public extension SwiftyPhotos {
    func requestAuthorization(resultHandler: @escaping ResultHandlerOfPhotoAuthrization) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                if authorizationStatus == .authorized {
                    resultHandler(true)
                } else {
                    resultHandler(false)
                }
            }
        case .restricted, .denied:
            print(">>>SwiftyPhotos : authorizationStatus denied")
            resultHandler(false)
        case .authorized:
            print(">>>SwiftyPhotos : authorizationStatus already authorized")
            resultHandler(true)
        default:
            print(">>>SwiftyPhotos : authorizationStatus unknown")
        }
    }
}

// MARK: - reload

public extension SwiftyPhotos {
    func reloadAll(resultHandler: @escaping ResultHandlerOfPhotoAuthrization) {
        requestAuthorization { (isPhotoAuthorized) in
            if isPhotoAuthorized {
                self.p_reloadAll()
            }
            resultHandler(isPhotoAuthorized)
        }
    }
    
    fileprivate func p_reloadAll() {
        let handleAssetCollection = { (assetCollection: PHAssetCollection) in
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType=1")
            
            let photoAlbum = PhotoAlbumModel(assetCollection)
            self.allAlbums.append(photoAlbum)
        }
        
        // All Photos
        let allPhotosAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        allPhotosAlbum.enumerateObjects(_:) { (assetCollection, idx, stop) in
            handleAssetCollection(assetCollection)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects(_:) { (assetCollection, idx, stop) in
            guard let albumName = assetCollection.localizedTitle else {
                print(">>>SwiftyPhotos : failed to fetch albumName of assetCollection")
                return
            }
            if AlbumsOfIOS.contains(albumName) {
                handleAssetCollection(assetCollection)
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
    func isAlbumExisting(albumName: String) -> Bool {
        if let _ = photoAlbumWithName(albumName) {
            return true
        }
        return false
    }
    
    func photoAlbumWithName(_ albumName: String) -> PhotoAlbumModel? {
        return allAlbums.filter { (photoAlbum) -> Bool in
            albumName == photoAlbum.name
        }.first
    }
    
    @discardableResult
    func createAlbum(_ albumName: String) -> Bool {
        if let _ = photoAlbumWithName(albumName) {
            print(">>>SwiftyPhotos : album \(albumName) is already existing")
            return false
        }
        
        var isAlbumCreated = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) { (isSuccess, error) in
            if isSuccess == true {
                print(">>>SwiftyPhotos : succeed to create album : \(albumName)")
                isAlbumCreated = true
            } else {
                print(">>>SwiftyPhotos : failed to create album : \(albumName). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        
        allAlbums.removeAll()
        p_reloadAll()
        return isAlbumCreated
    }
}

// MARK: - Photo

public extension SwiftyPhotos {
    func saveImage(_ image: UIImage, intoAlbum albumName: String, withLocation location: CLLocation?, resultHandler: @escaping ResultHandlerOfPhotoOperation) -> Bool {
        createAlbum(albumName)
        
        guard let photoAlbum = photoAlbumWithName(albumName) else {
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
                print(">>>SwiftyPhotos : succeed to save image to album : \(albumName)")
                isImageSaved = true
            } else {
                print(">>>SwiftyPhotos : failed to save image to album : \(albumName). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        resultHandler(isImageSaved, nil)
        
        return isImageSaved
    }
    
    func deleteAsset(_ photoAsset: PhotoAssetModel, resultHandler: @escaping ResultHandlerOfPhotoOperation) -> Bool {
        var isAssetDeleted = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        PHPhotoLibrary.shared().performChanges({
            let fastEnumerate: NSArray = [photoAsset.asset]
            PHAssetChangeRequest.deleteAssets(fastEnumerate)
        }) { (isSuccess, error) in
            if isSuccess == true {
                print(">>>SwiftyPhotos : succeed to delete asset : \(photoAsset.name)")
                isAssetDeleted = true
            } else {
                print(">>>SwiftyPhotos : failed to delete asset : \(photoAsset.name). \(String(describing: error))")
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        resultHandler(isAssetDeleted, nil)
        
        return isAssetDeleted
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension SwiftyPhotos: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        for (_, photoAlbum) in allAlbums.enumerated() {
            if let changeDetails = changeInstance.changeDetails(for: photoAlbum.fetchResult) {
                photoAlbum.changeWithDetails(changeDetails)
            }
        }
    }
}

