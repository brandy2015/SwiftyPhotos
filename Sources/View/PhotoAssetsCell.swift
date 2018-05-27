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
    
    public var imageRequestID: PHImageRequestID?
    
    public var photoAsset: PhotoAssetModel! {
        didSet {
            self.imageRequestID = self.photoAsset.requestThumbnail(resultHandler: { (image, info) in
                DispatchQueue.main.async {
                    if let info = info {
                        if let requestID = info[PHImageResultRequestIDKey] as? NSNumber {
                            if requestID.int32Value == self.imageRequestID {
                                self.thumbnail.image = image
                            }
                        }
                    }
                }
            })
        }
    }
    
    private lazy var thumbnail: UIImageView = {
        let iv = UIImageView(frame: self.bounds)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.addSubview(self.thumbnail)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
