//
//  PhotoAlbumsCell.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit

class PhotoAlbumsCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCount: UILabel!
    
    var albumModel: PhotoAlbumModel! {
        didSet {
            lbTitle.text = albumModel.name
            lbCount.text = "\(albumModel.photosCount)"
            
            
            DispatchQueue.global().async {
                _ = SwiftyPhotos.shared.requestThumbnailForAsset(asset: self.albumModel.thumbnail) { (image, info) in
                    DispatchQueue.main.async {
                        self.iconView.image = image
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
}

// MARK: - setupUI
extension PhotoAlbumsCell {
    func setupUI() {
        backgroundColor = UIColor.white
        isExclusiveTouch = true
    }
}
