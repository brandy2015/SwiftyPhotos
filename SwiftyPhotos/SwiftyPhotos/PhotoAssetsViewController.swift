//
//  PhotoAssetsViewController.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit

class PhotoAssetsViewController: UIViewController {

    var photoAlbum: PhotoAlbumModel! {
        didSet {
            DispatchQueue.main.async {
                self.lbTitle.text = "△ \(self.photoAlbum.name)"
                self.photoAssetsView.reload(self.photoAlbum)
            }
        }
    }
    
    // MARK: - toolBar
    fileprivate lazy var toolBar: UIView = {
        let height: CGFloat = 40.0
        let v: UIView = UIView(frame: CGRect(x: 0,
                                             y: self.view.frame.height - height,
                                             width: self.view.frame.width,
                                             height: height))
        v.backgroundColor = UIColor.white
        return v
    }()
    fileprivate lazy var lbTitle: UILabel = {
        let height = self.toolBar.frame.height
        let lb: UILabel = UILabel(frame:CGRect(x: height,
                                               y: 0,
                                               width: self.toolBar.frame.width - height * 2,
                                               height: height))
        lb.textColor = UIColor.black
        lb.textAlignment = .center
        return lb
    }()
    
    // MARK: - gestures
    
    fileprivate lazy var tapGestureShowOrHideAlbumsToolBar: UITapGestureRecognizer = {
        let g: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                               action: #selector(actionShowOrHideAlbums(_:)))
        return g
    }()
    fileprivate lazy var tapGestureShowOrHideAlbumsMaskView: UITapGestureRecognizer = {
        let g: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                               action: #selector(actionShowOrHideAlbums(_:)))
        return g
    }()
    
    // MARK: - PhotoAlbumsView
    
    fileprivate lazy var photoAlbumsView: PhotoAlbumsView = {
        let height = (self.view.frame.height - self.toolBar.frame.height) / 2
        let frame = CGRect(x: 0,
                           y: self.view.frame.height - self.toolBar.frame.height - height,
                           width: self.view.frame.width,
                           height: height)
        let view: PhotoAlbumsView = PhotoAlbumsView(frame: frame)
        return view
    }()
    fileprivate lazy var photosAlbumsMaskView: UIView = {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width,
                           height: self.view.frame.height - self.toolBar.frame.height)
        let v: UIView = UIView(frame: frame)
        v.alpha = 0.6
        return v
    }()
    
    // MARK: - PhotoAssetsView
    
    fileprivate lazy var photoAssetsView: PhotoAssetsView = {
        let height = self.toolBar.frame.height
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width,
                           height: self.view.frame.height - height)
        let view = PhotoAssetsView(frame: frame, photoAlbum: self.photoAlbum, isKeepingPhotoRatio: false, cellCountOfLine: 3, cellOffset: 2.0)
        return view
    }()
    
    // albums tableView 是否显示
    
    fileprivate var isPhotoAlbumsViewShown: Bool = true {
        didSet {
            if self.isPhotoAlbumsViewShown == true {
                self.lbTitle.text = "▽ \(self.photoAlbum.name)"
                
                self.photosAlbumsMaskView.isHidden = false
                
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 1,
                               options: .curveEaseInOut,
                               animations: {
                                self.photosAlbumsMaskView.backgroundColor = UIColor.black
                                self.photoAlbumsView.transform = CGAffineTransform.identity
                }, completion: nil)
            } else {
                self.lbTitle.text = "△ \(self.photoAlbum.name)"
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.photosAlbumsMaskView.backgroundColor = UIColor.clear
                    self.photoAlbumsView.transform = CGAffineTransform(translationX: 0,
                                                                       y: UIScreen.main.bounds.height - self.photoAlbumsView.frame.minY)
                }, completion: { (finished) in
                    self.photosAlbumsMaskView.isHidden = true
                })
            }
        }
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftyPhotos.shared.reloadAll { (isPhotoAuthrized) in
            if isPhotoAuthrized {
                if let _ = SwiftyPhotos.shared.photoAlbumWithName("SwiftyPhotos") {
                } else {
                    _ = SwiftyPhotos.shared.createAlbum("SwiftyPhotos")
                }
                
                if let allPhotosAlbum = SwiftyPhotos.shared.allPhotoAlbums.first {
                    self.photoAlbum = allPhotosAlbum
                }
                
                DispatchQueue.main.async {
                    self.setupUI()
                }
            } else {
                print("please allow photo authorization status")
                DispatchQueue.main.async {
                    let alertVC = UIAlertController(title: "Fail to visit iPhone photo album", message: nil, preferredStyle: .alert)
                    let goSettings = UIAlertAction(title: "Go to Settings", style: .default, handler: { (alertAction) in
                        print("go to settings")
                        if let url = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertVC.addAction(goSettings)
                    alertVC.addAction(cancel)
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addGestures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeGestures()
    }
}

// MARK: - setupUI
extension PhotoAssetsViewController {
    fileprivate func setupUI() {
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.photoAssetsView)
        self.photoAssetsView.delegate = self
        
        self.view.addSubview(self.photosAlbumsMaskView)
        self.view.addSubview(self.photoAlbumsView)
        self.photoAlbumsView.delegate = self
        
        self.view.addSubview(self.toolBar)
        self.toolBar.addSubview(self.lbTitle)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isPhotoAlbumsViewShown = false
        }
    }
}

// MARK: - gestures
extension PhotoAssetsViewController {
    fileprivate func addGestures() {
        self.lbTitle.isUserInteractionEnabled = true
        self.lbTitle.addGestureRecognizer(self.tapGestureShowOrHideAlbumsToolBar)
        
        self.photosAlbumsMaskView.isUserInteractionEnabled = true
        self.photosAlbumsMaskView.addGestureRecognizer(self.tapGestureShowOrHideAlbumsMaskView)
    }
    
    fileprivate func removeGestures() {
        self.lbTitle.removeGestureRecognizer(self.tapGestureShowOrHideAlbumsToolBar)
        self.photosAlbumsMaskView.removeGestureRecognizer(self.tapGestureShowOrHideAlbumsMaskView)
    }
    
    @objc
    fileprivate func actionShowOrHideAlbums(_ sender: UITapGestureRecognizer) {
        self.isPhotoAlbumsViewShown = !self.isPhotoAlbumsViewShown
    }
}

// MARK: - PhotoAlbumsViewDelegate

extension PhotoAssetsViewController: PhotoAlbumsViewDelegate {
    func PhotoAlbumsViewDidSelectPhotoAlbum(_ photoAlbum: PhotoAlbumModel) {
        if self.photoAlbum.name != photoAlbum.name {
            self.photoAlbum = photoAlbum
        }
        self.isPhotoAlbumsViewShown = false
    }
}

// MARK: - PhotoAssetsViewDelegate

extension PhotoAssetsViewController: PhotoAssetsViewDelegate {
    func PhotoAssetsViewDidSelectPhoto(_ photoAsset: PhotoAssetModel) {
        let photoDetailVC = PhotoDetailViewController()
        photoDetailVC.photoAsset = photoAsset
        self.present(photoDetailVC, animated: true, completion: nil)
    }
}
