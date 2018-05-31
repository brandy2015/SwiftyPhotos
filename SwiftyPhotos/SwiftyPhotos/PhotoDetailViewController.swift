//
//  PhotoDetailViewController.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/7.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailViewController: UIViewController {

    var photoAsset: PhotoAssetModel!
    
    private lazy var zoomImageView: ZoomImageView = {
        let v = ZoomImageView(frame: self.view.bounds)
        return v
    }()
    
    private lazy var btnBack: UIButton = {
        let btn: UIButton = UIButton(frame: CGRect(x: 10, y: 20, width: 60, height: 40))
        btn.setTitle("Close", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(_actionBtnBack(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnDelete: UIButton = {
        let btn: UIButton = UIButton(frame: CGRect(x: self.view.frame.width - 10 - 60, y: 20, width: 60, height: 40))
        btn.setTitle("Delete", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(_actionBtnDelete(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var progressOfDownloadingInCloud: Double = 0.0
    
    deinit {
        if self.photoAsset.isInCloud {
            print("cancel request photo in icloud")
            self.photoAsset.cancelImageRequestInCloud()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.zoomImageView)
        self.view.addSubview(self.btnBack)
        self.view.addSubview(self.btnDelete)
        
        self.setupPhoto()
    }
    
    private func setupPhoto() {
        if self.photoAsset.isInCloud {
            print("photo in icloud")
            self.photoAsset.requestAvailableSizeImageInCloud { [weak self] (image, info) in
                if let image = image {
                    self?.zoomImageView.image = image
                }
            }
            self.photoAsset.requestMaxSizeImageInCloud(resultHandler: { [weak self] (image, info) in
                if let image = image {
                    self?.zoomImageView.image = image
                }
            }) { [weak self] (progress, error, stop, info) in
                self?.progressOfDownloadingInCloud = progress
                print("downloading progress of icloud photo: \(String(progress))")
            }
        } else {
            self.photoAsset.requestMaxSizeImage { [weak self] (image, info) in
                if let image = image {
                    self?.zoomImageView.image = image
                }
            }
        }
    }
    
    @objc
    private func _actionBtnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func _actionBtnDelete(_ sender: UIButton) {
//        if let image = self.zoomImageView.image {
//            _ = SwiftyPhotos.shared.saveImage(image, intoAlbum: "SwiftyPhotos", withLocation: nil) { (isImageSaved, nil) in
//                print("image saved: \(isImageSaved)")
//            }
//        }
        
        _ = SwiftyPhotos.shared.deleteAsset(self.photoAsset) { (isAssetDeleted, error) in
            print("asset deleted: \(isAssetDeleted)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
