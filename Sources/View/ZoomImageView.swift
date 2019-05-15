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
            imageView.image = image
        }
    }
    
    // double tap to room
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(_actionTapGesture(_:)))
        g.numberOfTapsRequired = 2
        return g
    }()
    
    // MARK: - subViews
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        addGestureRecognizer(tapGesture)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions

public extension ZoomImageView {
    @objc
    private func _actionTapGesture(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let rect = _zoomRectWithPoint(point: touchPoint, tScale: scrollView.maximumZoomScale)
            scrollView.zoom(to: rect, animated: true)
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
        showSize.width = min(frame.width, scrollView.frame.width)
        showSize.height = min(frame.height, scrollView.frame.height)
        
        let scale = showSize.width / showSize.height
        
        if width / height > scale {
            width = height * scale
        } else {
            height = width / scale
        }
        
        return CGRect(x: ox, y: oy, width: width, height: height)
    }
}

// MARK: - UIScrollViewDelegate

extension ZoomImageView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // imageView
        guard let imageView = scrollView.subviews.first else { return }
        
        let offsetX = max((scrollView.frame.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.frame.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                   y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
}

