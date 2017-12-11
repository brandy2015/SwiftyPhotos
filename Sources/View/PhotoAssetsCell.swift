//
//  PhotoAssetsCell.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos

class PhotoAssetsCell: UICollectionViewCell {
    
    // 通过identifier防止cell复用时thumbnail错乱
    var assetLocalIdentifier = ""
    var imageRequestID: PHImageRequestID!
    var photoAsset: PhotoAssetModel! {
        willSet {
            imageRequestID = SwiftyPhotos.shared
                .requestThumbnailForAsset(asset: newValue.asset) {
                    [weak self] (image, info) in
                    guard let image = image else { return }
                    guard let sself = self else { return }
                    
                    DispatchQueue.main.async {
                        sself.thumbnail.image = image
                    }
            }
        }
    }
    
    lazy var thumbnail: UIImageView = {
        let iv = UIImageView(frame: self.bounds)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - setupUI
extension PhotoAssetsCell {
    func setupUI() {
        backgroundColor = UIColor.white
        clipsToBounds = true
        addSubview(thumbnail)
    }
}
