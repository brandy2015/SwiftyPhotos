//
//  PhotoAlbumsView.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 2017/12/6.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit


protocol PhotoAlbumsViewDelegate: class {
    func PhotoAlbumsViewClose()
    func PhotoAlbumsViewDidSelectAlbum(_ albumModel: PhotoAlbumModel)
}


class PhotoAlbumsView: UIView {

    weak var delegate: PhotoAlbumsViewDelegate?
    
    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: self.bounds, style: .plain)
        
        tableView.register(UINib(nibName: "PhotoAlbumsCell", bundle: nil), forCellReuseIdentifier: "PhotoAlbumsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60.0
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoAlbumsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SwiftyPhotos.shared.allAlbums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PhotoAlbumsCell = tableView.dequeueReusableCell(withIdentifier: "PhotoAlbumsCell", for: indexPath) as! PhotoAlbumsCell
        cell.albumModel = SwiftyPhotos.shared.allAlbums[indexPath.row]
        
        return cell
    }
}

extension PhotoAlbumsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumModel = SwiftyPhotos.shared.allAlbums[indexPath.row]
        delegate?.PhotoAlbumsViewDidSelectAlbum(albumModel)
    }
}
