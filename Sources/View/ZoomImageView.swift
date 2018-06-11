//
//  ZoomImageView.swift
//  SwiftyPhotos
//
//  Created by Chris Hu on 31/05/2018.
//  Copyright © 2018 com.icetime. All rights reserved.
//

import UIKit

/// UIView supports zooming and double tap.
public class ZoomImageView: UIView {

    public var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    fileprivate lazy var imageView: UIImageView = {
        let v = UIImageView(frame: self.bounds)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    fileprivate lazy var scrollView: UIScrollView = {
        let v = UIScrollView(frame: self.bounds)
        v.bounces = false
        v.delegate = self
        v.minimumZoomScale = 1.0
        v.maximumZoomScale = 4.0
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    // double tap to room
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(_actionTapGesture(_:)))
        g.numberOfTapsRequired = 2
        return g
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        
        self.addGestureRecognizer(self.tapGesture)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func _actionTapGesture(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            let rect = self._zoomRectWithPoint(point: touchPoint, tScale: self.scrollView.maximumZoomScale)
            self.scrollView.zoom(to: rect, animated: true)
        }
    }
    
    @objc
    private func _zoomRectWithPoint(point: CGPoint, tScale: CGFloat) -> CGRect {
        var width = frame.width / tScale
        var height = frame.height / tScale
        
        let ox = point.x - width / 2
        let oy = point.y - height / 2
        
        // calculate the offset
        var showSize = CGSize.zero
        showSize.width = min(frame.width, self.scrollView.frame.width)
        showSize.height = min(frame.height, self.scrollView.frame.height)
        
        let scale = showSize.width / showSize.height
        
        if width / height > scale {
            width = height * scale
        } else {
            height = width / scale
        }
        
        return CGRect(x: ox, y: oy, width: width, height: height)
    }
}

extension ZoomImageView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // imageView
        guard let imageView = self.scrollView.subviews.first else { return }
        
        let offsetX = max((self.scrollView.frame.width - self.scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((self.scrollView.frame.height - self.scrollView.contentSize.height) * 0.5, 0.0)
        
        imageView.center = CGPoint(x: self.scrollView.contentSize.width * 0.5 + offsetX,
                                   y: self.scrollView.contentSize.height * 0.5 + offsetY)
    }
    
}

