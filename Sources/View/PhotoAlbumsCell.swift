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
    
    public var imageRequestID: PHImageRequestID?
    
    public var albumModel: PhotoAlbumModel! {
        didSet {
            DispatchQueue.main.async {
                self.lbTitle.text = self.albumModel.name
                self.lbCount.text = "\(self.albumModel.photoAssets.count)"
            }
        
            imageRequestID = albumModel.lastPhotoAsset?.requestThumbnail(resultHandler: { (image, info) in
                guard let image = image, let info = info else { return }
                guard let requestID = info[PHImageResultRequestIDKey] as? NSNumber else { return }
                if requestID.int32Value == self.imageRequestID {
                    DispatchQueue.main.async {
                        self.iconView.image = image
                    }
                }
            })
        }
    }
    
    // MARK: - subViews
    
    public lazy var iconView: UIImageView = {
        let v = UIImageView(frame: CGRect(x: 10.0, y: 10.0, width: 40.0, height: 40.0))
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    public lazy var lbTitle: UILabel = {
        let offset = CGFloat(10.0)
        let v = UILabel(frame: CGRect(x: self.iconView.frame.maxX + offset, y: self.iconView.frame.minY + 5, width: self.frame.size.width - 50.0, height: 14))
        v.font = UIFont.systemFont(ofSize: 14)
        return v
    }()
    
    public lazy var lbCount: UILabel = {
        let v = UILabel(frame: CGRect(x: self.lbTitle.frame.minX, y: self.lbTitle.frame.maxY + 5, width: self.lbTitle.frame.width, height: 12))
        v.font = UIFont.systemFont(ofSize: 12)
        v.textColor = UIColor.gray
        return v
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.white
        isExclusiveTouch = true
        clipsToBounds = true
        
        addSubview(iconView)
        addSubview(lbTitle)
        addSubview(lbCount)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
