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
    
    // albums tableView 是否显示
    
    fileprivate var isPhotoAlbumsViewShown: Bool = true {
        didSet {
            if isPhotoAlbumsViewShown == true {
                lbTitle.text = "▽ \(photoAlbum.name)"
                
                photosAlbumsMaskView.isHidden = false
                
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
                lbTitle.text = "△ \(photoAlbum.name)"
                
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
    
    // MARK: - subViews
    fileprivate lazy var toolBar: UIView = {
        let height: CGFloat = 40.0
        let v: UIView = UIView(frame: CGRect(x: 0,
                                             y: view.frame.height - height,
                                             width: view.frame.width,
                                             height: height))
        v.backgroundColor = UIColor.white
        return v
    }()
    fileprivate lazy var lbTitle: UILabel = {
        let height = toolBar.frame.height
        let lb: UILabel = UILabel(frame:CGRect(x: height,
                                               y: 0,
                                               width: toolBar.frame.width - height * 2,
                                               height: height))
        lb.textColor = UIColor.black
        lb.textAlignment = .center
        return lb
    }()
    
    // MARK: - PhotoAlbumsView
    
    fileprivate lazy var photoAlbumsView: PhotoAlbumsView = {
        let height = (view.frame.height - toolBar.frame.height) / 2
        let frame = CGRect(x: 0,
                           y: view.frame.height - toolBar.frame.height - height,
                           width: view.frame.width,
                           height: height)
        let view: PhotoAlbumsView = PhotoAlbumsView(frame: frame)
        return view
    }()
    fileprivate lazy var photosAlbumsMaskView: UIView = {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: view.frame.width,
                           height: view.frame.height - toolBar.frame.height)
        let v: UIView = UIView(frame: frame)
        v.alpha = 0.6
        return v
    }()
    
    // MARK: - PhotoAssetsView
    
    fileprivate lazy var photoAssetsView: PhotoAssetsView = {
        let height = toolBar.frame.height
        let frame = CGRect(x: 0,
                           y: 0,
                           width: view.frame.width,
                           height: view.frame.height - height)
        let view = PhotoAssetsView(frame: frame, photoAlbum: photoAlbum, isKeepingPhotoRatio: false, cellCountOfLine: 3, cellOffset: 2.0)
        return view
    }()
}

// MARK: - LifeCycle

extension PhotoAssetsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftyPhotos.shared.reloadAll { (isPhotoAuthrized) in
            if isPhotoAuthrized {
                if let _ = SwiftyPhotos.shared.photoAlbumWithName("SwiftyPhotos") {
                } else {
                    _ = SwiftyPhotos.shared.createAlbum("SwiftyPhotos")
                }
                
                if let allPhotosAlbum = SwiftyPhotos.shared.allAlbums.first {
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
                        if let url = URL(string: UIApplication.openSettingsURLString) {
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
        
        addGestures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeGestures()
    }
}

// MARK: - UI

extension PhotoAssetsViewController {
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(photoAssetsView)
        photoAssetsView.delegate = self
        
        view.addSubview(photosAlbumsMaskView)
        view.addSubview(photoAlbumsView)
        photoAlbumsView.delegate = self
        
        view.addSubview(toolBar)
        toolBar.addSubview(lbTitle)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isPhotoAlbumsViewShown = false
        }
    }
}

// MARK: - Gestures

extension PhotoAssetsViewController {
    fileprivate func addGestures() {
        lbTitle.isUserInteractionEnabled = true
        lbTitle.addGestureRecognizer(tapGestureShowOrHideAlbumsToolBar)
        
        photosAlbumsMaskView.isUserInteractionEnabled = true
        photosAlbumsMaskView.addGestureRecognizer(tapGestureShowOrHideAlbumsMaskView)
    }
    
    fileprivate func removeGestures() {
        lbTitle.removeGestureRecognizer(tapGestureShowOrHideAlbumsToolBar)
        photosAlbumsMaskView.removeGestureRecognizer(tapGestureShowOrHideAlbumsMaskView)
    }
    
    @objc
    fileprivate func actionShowOrHideAlbums(_ sender: UITapGestureRecognizer) {
        isPhotoAlbumsViewShown = !isPhotoAlbumsViewShown
    }
}

// MARK: - PhotoAlbumsViewDelegate

extension PhotoAssetsViewController: PhotoAlbumsViewDelegate {
    func PhotoAlbumsViewDidSelectPhotoAlbum(_ photoAlbum: PhotoAlbumModel) {
        if photoAlbum.name != photoAlbum.name {
            self.photoAlbum = photoAlbum
        }
        isPhotoAlbumsViewShown = false
    }
}

// MARK: - PhotoAssetsViewDelegate

extension PhotoAssetsViewController: PhotoAssetsViewDelegate {
    func PhotoAssetsViewDidSelectPhotoInAlbum(_ photoAlbum: PhotoAlbumModel, at indexPath: IndexPath) {
        let photoDetailVC = PhotoDetailViewController()
        let photoAsset = photoAlbum.photoAssets[indexPath.item]
        photoDetailVC.photoAsset = photoAsset
        present(photoDetailVC, animated: true, completion: nil)
    }
}
