//
//  PhotoAlbumsCell.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit
import Photos

public class PhotoAlbumsCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCount: UILabel!
    
    public var imageRequestID: PHImageRequestID?
    
    public var albumModel: PhotoAlbumModel! {
        didSet {
            DispatchQueue.main.async {
                self.lbTitle.text = self.albumModel.name
                self.lbCount.text = "\(self.albumModel.photoAssets.count)"
            }
        
            self.imageRequestID = self.albumModel.lastPhotoAsset?.requestThumbnail(resultHandler: { (image, info) in
                DispatchQueue.main.async {
                    if let info = info {
                        if let requestID = info[PHImageResultRequestIDKey] as? NSNumber {
                            if requestID.int32Value == self.imageRequestID {
                                self.iconView.image = image
                            }
                        }
                    }
                }
            })
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.white
        self.isExclusiveTouch = true
    }
}
