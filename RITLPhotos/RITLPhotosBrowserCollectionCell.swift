//
//  RITLPhotosBrowserCollectionCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/27.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

///
public class RITLPhotosBrowserCollectionCell: UICollectionViewCell,RITLPhotosBrowserUpdater {
    
    /// 用于标记图片的id
    var assetIdentifer = ""
    /// 资源
    weak var asset: PHAsset?
    /// 显示图片的imageView
    var iconImageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func buildView() {}
    public func iconImageSetComplete() {}
}


/// 单击之后的通知
let RITLPhotosBrowserTapNotificationName = Notification.Name("RITLPhotosBrowserTapNotificationName")


/// 图片
public class RITLPhotosBrowserNormalCollectionCell: RITLPhotosBrowserCollectionCell, UIScrollViewDelegate, RITLPhotosBrowserResetter {
    
    /// 用于缩放的滚动视图
    private(set) var scrollView = UIScrollView()
    /// 是否已经缩放
    private var isScale = false
    
    /// 手势
    private let tapGesture = UITapGestureRecognizer()
    private let doubleTapGesture = UITapGestureRecognizer()
    
    private let minScaleZoom: CGFloat = 1.0
    private let maxScaleZoom: CGFloat = 2.0
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        scrollView.zoomScale = 1.0
    }
    
    public override func buildView() {
        super.buildView()
        
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.minimumZoomScale = minScaleZoom
        scrollView.maximumZoomScale = maxScaleZoom
        //追加监听
        if let pinchGestureRecognizer = scrollView.pinchGestureRecognizer {
            pinchGestureRecognizer.addTarget(self, action: #selector(pinchGestureRecognizerDidChanged(recognizer:)))
        }
        
        iconImageView.contentMode = .scaleAspectFit
        //单击
        tapGesture.numberOfTapsRequired = 1
        tapGesture.require(toFail: doubleTapGesture)
        scrollView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(tapGestureDidAction(tapGesture:)))
        //双击
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        doubleTapGesture.addTarget(self, action: #selector(tapGestureDidAction(tapGesture:)))
        
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(iconImageView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.edges.height.width.equalToSuperview()
        }
    }
    
    @objc func tapGestureDidAction(tapGesture: UITapGestureRecognizer) {
        //如果是单击
        if tapGesture == self.tapGesture {
            NotificationCenter.default.post(name: RITLPhotosBrowserTapNotificationName, object: nil); return
        }
        //双击回调
        guard tapGesture == doubleTapGesture else { return }
        //用于缩放
        if scrollView.zoomScale != 1 {
            scrollView.setZoomScale(1.0, animated: true); return
        }
        let distance = min(frame.width, frame.height)
        let (width, scale, point) = (distance, distance / maxScaleZoom, tapGesture.location(in: iconImageView))
        //对点进行处理
        let originX = max(0, point.x - width / scale)
        let originY = max(0, point.y - width / scale)
        //计算位置
        let rect = CGRect(x: originX, y: originY, width: width / scale, height: width / scale)
        //缩放
        scrollView.zoom(to: rect, animated: true)
    }
    
    ///
    @objc func pinchGestureRecognizerDidChanged(recognizer: UIPinchGestureRecognizer) {
        /// 重置iconImageView
        func resetIconImageViewOrigin() {
            guard scrollView.zoomScale <= 1.0 else { return }
            UIView.animate(withDuration: 0.2) {
                self.iconImageView.frame.origin = .zero
            }
        }
        
        switch recognizer.state {
        case .ended: resetIconImageViewOrigin()
        default: return
        }
    }
    
    //MARK: UIScrollViewDelegate
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return iconImageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //小于1.0
        guard scrollView.zoomScale < 1.0 else { return }
        //居中显示即可
        iconImageView.center = CGPoint(x: scrollView.bounds.width / 2, y: scrollView.bounds.height / 2)
    }
    
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(scale, animated: true)
    }
    
    
    public override func iconImageSetComplete() {
        //对缩放进行设置
//        guard let asset = asset else { return }
//        let (height, width) = (asset.pixelHeight / 2, asset.pixelWidth / 2)
//        let limit = max(width, height)
//        let scale = (height > width ?
//            { CGFloat(limit) / CGFloat(max(1, Int(iconImageView.bounds.size.height))) }() :
//            { CGFloat(limit) / CGFloat(max(1, Int(iconImageView.bounds.size.width))) }())
//        scrollView.maximumZoomScale = max(2,scale)
        print("1")
    }
    
}


///
public class RITLPhotosBrowserLiveCollectionCell: RITLPhotosBrowserCollectionCell {
    
}
