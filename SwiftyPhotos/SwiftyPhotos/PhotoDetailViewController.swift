//
//  PhotoDetailViewController.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/7.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    var image: UIImage?
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView(frame: self.view.bounds)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.imageView)
        self.imageView.image = image
    }
}
