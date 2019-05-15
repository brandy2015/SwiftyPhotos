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
    
    // MARK: - subViews
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: self.bounds, style: .plain)
        
        tableView.register(PhotoAlbumsCell.classForCoder(), forCellReuseIdentifier: "PhotoAlbumsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60.0
        
        return tableView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UITableViewDataSource

extension PhotoAlbumsView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SwiftyPhotos.shared.allAlbums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoAlbumsCell", for: indexPath) as! PhotoAlbumsCell
        
        cell.albumModel = SwiftyPhotos.shared.allAlbums[indexPath.row]
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PhotoAlbumsView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoAlbum = SwiftyPhotos.shared.allAlbums[indexPath.row]
        delegate?.PhotoAlbumsViewDidSelectPhotoAlbum(photoAlbum)
    }
}
