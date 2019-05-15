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
    private var progressOfDownloadingInCloud: Double = 0.0
    
    // MARK: - subViews
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
    
    deinit {
        if self.photoAsset.isInCloud {
            print("cancel request photo in icloud")
            self.photoAsset.cancelImageRequestInCloud()
        }
    }
}

// MARK: - LifeCycle

extension PhotoDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(zoomImageView)
        view.addSubview(btnBack)
        view.addSubview(btnDelete)
        
        setupPhoto()
    }
    
}

// MARK: - Actions

extension PhotoDetailViewController {
    @objc
    private func _actionBtnBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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

// MARK: - Private

extension PhotoDetailViewController {
    private func setupPhoto() {
        if photoAsset.isInCloud {
            print("photo in icloud")
            photoAsset.requestAvailableSizeImageInCloud { [weak self] (image, info) in
                self?.zoomImageView.image = image
            }
            photoAsset.requestMaxSizeImageInCloud(resultHandler: { [weak self] (image, info) in
                self?.zoomImageView.image = image
            }) { [weak self] (progress, error, stop, info) in
                print("downloading progress of icloud photo: \(progress)")
                self?.progressOfDownloadingInCloud = progress
            }
        } else {
            photoAsset.requestMaxSizeImage { [weak self] (image, info) in
                self?.zoomImageView.image = image
            }
        }
    }
}
