//
//  PhotoAlbumsView.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit


public protocol PhotoAlbumsViewDelegate: class {
    func PhotoAlbumsViewDidSelectPhotoAlbum(_ photoAlbum: PhotoAlbumModel)
}


public class PhotoAlbumsView: UIView {

    public weak var delegate: PhotoAlbumsViewDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: self.bounds, style: .plain)
        
        tableView.register(UINib(nibName: "PhotoAlbumsCell", bundle: nil), forCellReuseIdentifier: "PhotoAlbumsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60.0
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.tableView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoAlbumsView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SwiftyPhotos.shared.allPhotoAlbums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoAlbumsCell", for: indexPath) as! PhotoAlbumsCell
        
        cell.albumModel = SwiftyPhotos.shared.allPhotoAlbums[indexPath.row]
        
        return cell
    }
}

extension PhotoAlbumsView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = self.delegate {
            let photoAlbum = SwiftyPhotos.shared.allPhotoAlbums[indexPath.row]
            delegate.PhotoAlbumsViewDidSelectPhotoAlbum(photoAlbum)
        }
    }
}
