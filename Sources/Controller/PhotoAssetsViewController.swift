//
//  PhotoAssetsViewController.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit

// cell之间的间隔
fileprivate let kCellOffset: CGFloat        = 2.0
// 一行几个cell
fileprivate let kCellCountOfALine: Int      = 4

class PhotoAssetsViewController: UIViewController {

    var albumModel: PhotoAlbumModel! {
        didSet {
            DispatchQueue.global().async {
                self.photoAssets = SwiftyPhotos.shared.photoAssetsByAlbumModel(self.albumModel)
                DispatchQueue.main.async {
                    self.lbTitle.text = "△ \(self.albumModel.name)"
                    self.isPhotoAlbumsViewHidden = true
                    self.photosCollectionView.reloadData()
                    //                    self.scrollToLastestPhoto()
                    let lastIndexPath = IndexPath(item: self.photosCollectionView.numberOfItems(inSection: 0) - 1, section: 0)
                    self.photosCollectionView.scrollToItem(at: lastIndexPath, at: .centeredVertically, animated: false)
                }
            }
        }
    }
    var photoAssets = Array<PhotoAssetModel>()
    
    // MARK: - toolBar
    lazy var toolBar: UIView = {
        let height: CGFloat = 40.0
        let v: UIView = UIView(frame: CGRect(x: 0,
                                             y: self.view.frame.height - height,
                                             width: self.view.frame.width,
                                             height: height))
        return v
    }()
    lazy var btnBack: UIButton = {
        let height = self.toolBar.frame.height
        let btn: UIButton = UIButton(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: height,
                                                   height: height))
        btn.setImage(UIImage(named: "btn.common.back"), for: .normal)
        btn.addTarget(self, action: #selector(_actionBtnBack(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var lbTitle: UILabel = {
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
    fileprivate lazy var tapGestureSelectAlbums: UITapGestureRecognizer = {
        let g: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                               action: #selector(actionSelectAlbums(_:)))
        return g
    }()
    fileprivate lazy var tapGestureCloseAlbums: UITapGestureRecognizer = {
        let g: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                               action: #selector(actionCloseAlbums(_:)))
        return g
    }()
    
    // MARK: - photos collectionView
    lazy var photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let height = self.toolBar.frame.height
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width,
                           height: self.view.frame.height - height)
        let cv: UICollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        
        layout.minimumInteritemSpacing = kCellOffset
        layout.minimumLineSpacing = kCellOffset
        
        let itemWidth = (cv.frame.width - kCellOffset * 3) / CGFloat(kCellCountOfALine)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        cv.register(PhotoAssetsCell.classForCoder(), forCellWithReuseIdentifier: "PhotoAssetsCell")
        
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    
    var isFirstEnter = true
    
    /// photos collectionView 是否滚动到 bottom
    var isScrolledToBottom = false
    
    // MARK: - albums tableView
    lazy var photoAlbumsView: PhotoAlbumsView = {
        let height = CGFloat((self.view.frame.height - self.toolBar.frame.height) * 2 / 3)
        let frame = CGRect(x: 0,
                           y: self.view.frame.height - self.toolBar.frame.height - height,
                           width: self.view.frame.width,
                           height: height)
        let tv: PhotoAlbumsView = PhotoAlbumsView(frame: frame)
        tv.delegate = self
        return tv
    }()
    lazy var photosAlbumsMaskView: UIView = {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.width,
                           height: self.view.frame.height - self.toolBar.frame.height)
        let v: UIView = UIView(frame: frame)
        v.isUserInteractionEnabled = true
        v.addGestureRecognizer(self.tapGestureCloseAlbums)
        return v
    }()
    
    /// albums tableView 是否隐藏
    var isPhotoAlbumsViewHidden: Bool = true {
        didSet {
            if isFirstEnter {
                return
            }
            
            if isPhotoAlbumsViewHidden {
                UIView.animate(withDuration: 0.3, animations: { 
                    self.photosAlbumsMaskView.backgroundColor = UIColor.clear
                    self.photoAlbumsView.transform = CGAffineTransform(translationX: 0,
                                                                       y: UIScreen.main.bounds.height - self.photoAlbumsView.frame.minY)
                }, completion: { (finished) in
                    self.photosAlbumsMaskView.isHidden = true
                })
            } else {
                self.photosAlbumsMaskView.isHidden = false
                
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 1,
                               options: .curveEaseInOut,
                               animations: {
                                self.photosAlbumsMaskView.backgroundColor = UIColor.black
                                self.photoAlbumsView.transform = CGAffineTransform.identity
                               },
                               completion: nil)
            }
        }
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SwiftyPhotos.shared.allAlbums.count > 0 {
            albumModel = SwiftyPhotos.shared.allAlbums.first
        }
        
        setupUI()
        
        isFirstEnter = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addGestures()
        addNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isScrolledToBottom {
            scrollToLastestPhoto()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeGestures()
        removeNotifications()
    }
    
    // Override to action for image selection
    func didSelectImageFromSwiftyPhotos(_ image: UIImage) {
        
    }
}

// MARK: - setupUI
extension PhotoAssetsViewController {
    func setupUI() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(photosCollectionView)
        
        view.addSubview(photosAlbumsMaskView)
        view.addSubview(photoAlbumsView)
        isPhotoAlbumsViewHidden = true
        
        view.addSubview(toolBar)
        toolBar.addSubview(lbTitle)
        toolBar.addSubview(btnBack)
    }
    
    func scrollToLastestPhoto() {
        if photosCollectionView.contentSize.height > 0 {
            isScrolledToBottom = true
            
        }
    }
    
}

// MARK: - actions
extension PhotoAssetsViewController {
    @objc
    func _actionBtnBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - gestures
extension PhotoAssetsViewController {
    func addGestures() {
        self.lbTitle.isUserInteractionEnabled = true
        self.lbTitle.addGestureRecognizer(self.tapGestureSelectAlbums)
    }
    
    func removeGestures() {
        self.lbTitle.removeGestureRecognizer(self.tapGestureSelectAlbums)
    }
    
    @objc
    func actionSelectAlbums(_ sender: UITapGestureRecognizer) {
        _closeAlbums()
    }
    
    @objc
    func actionCloseAlbums(_ sender: UITapGestureRecognizer) {
        _closeAlbums()
    }
    
    func _closeAlbums() {
        DispatchQueue.main.async {
            self.isPhotoAlbumsViewHidden = !self.isPhotoAlbumsViewHidden
            
            if self.isPhotoAlbumsViewHidden {
                self.lbTitle.text = "△ \(self.albumModel.name)"
            } else {
                self.lbTitle.text = "▽ \(self.albumModel.name)"
            }
        }
    }
}

// MARK: - notifications
extension PhotoAssetsViewController {
    func addNotifications() {
        
    }
    
    func removeNotifications() {
        
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoAssetsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAssetsCell",
                                                      for: indexPath) as! PhotoAssetsCell
        
        cell.photoAsset = photoAssets[indexPath.item]
        
        return cell
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.15, animations: { 
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (finished) in
            UIView.animate(withDuration: 0.15, animations: { 
                cell.transform = CGAffineTransform.identity
            })
        }
    }
     */
    
}

// MARK: - UICollectionViewDelegate
extension PhotoAssetsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoAsset = SwiftyPhotos.shared.allAssets[indexPath.item]
        SwiftyPhotos.shared.requestScreenSizeImageForAsset(asset: photoAsset.asset) { (image, info) in
            if let image = image {
                self.didSelectImageFromSwiftyPhotos(image)
            }
        }
    }
}

// MARK: - PhotoAlbumsViewDelegate
extension PhotoAssetsViewController: PhotoAlbumsViewDelegate {
    func PhotoAlbumsViewClose() {
        isPhotoAlbumsViewHidden = true
    }
    
    func PhotoAlbumsViewDidSelectAlbum(_ albumModel: PhotoAlbumModel) {
        if self.albumModel.name != albumModel.name {
            self.albumModel = albumModel
        } else {
            self.isPhotoAlbumsViewHidden = true
        }
    }
}
