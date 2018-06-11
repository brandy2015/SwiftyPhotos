//
//  PhotoAssetsCell.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos

public class PhotoAssetsCell: UICollectionViewCell {
    
    public var imageRequestID: PHImageRequestID?
    
    public var photoAsset: PhotoAssetModel! {
        didSet {
            self.imageRequestID = self.photoAsset.requestThumbnail(resultHandler: { [weak self] (image, info) in
                DispatchQueue.main.async {
                    if let info = info {
                        if let requestID = info[PHImageResultRequestIDKey] as? NSNumber {
                            if let sself = self {
                                if requestID.int32Value == sself.imageRequestID {
                                    sself.thumbnail.image = image
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    /// whether to keep photo ratio
    /// must be set before photoAsset
    public var isKeepingPhotoRatio: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isKeepingPhotoRatio {
                    self.thumbnail.contentMode = .scaleAspectFit
                    let height = self.frame.size.width * self.photoAsset.photoSize.height / self.photoAsset.photoSize.width
                    self.thumbnail.frame = CGRect(x: 0,
                                                  y: self.frame.size.height - height,
                                                  width: self.frame.size.width,
                                                  height: height)
                } else {
                    self.thumbnail.contentMode = .scaleAspectFill
                    self.thumbnail.frame = self.bounds
                }
            }
        }
    }
    
    public lazy var thumbnail: UIImageView = {
        let iv = UIImageView(frame: self.bounds)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.addSubview(self.thumbnail)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
