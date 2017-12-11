//
//  ViewController.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit

class ViewController: PhotoAssetsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didSelectImageFromSwiftyPhotos(_ image: UIImage) {
        let photoDetailVC = PhotoDetailViewController()
        photoDetailVC.image = image
        self.navigationController?.pushViewController(photoDetailVC, animated: true)
    }
}

