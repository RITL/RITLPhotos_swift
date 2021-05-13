//
//  RITLPhotosBrowserCollectionCell.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/27.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

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
        contentView.backgroundColor = .black
        iconImageView.contentMode = .scaleAspectFit
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


//MARK: 普通的图片
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
        
        scrollView.ritl_photos_anchorEdge(to: contentView)
        iconImageView.ritl_photos_anchorEdge(to: scrollView)
        iconImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
//        scrollView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
//        iconImageView.snp.makeConstraints { (make) in
//            make.edges.height.width.equalToSuperview()
//        }
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
//        ritl_p_print("1")
    }
    
}


//MARK: Live的图片
///

public class RITLPhotosBrowserLiveCollectionCell: RITLPhotosBrowserCollectionCell,RITLPhotosBrowserResetter {
    
    /// 显示livePhoto的图标
    let liveBadgeImageView = UIImageView()
    /// 描述
    let liveLabel = UILabel()
    /// 用于播放的视图
    @available(iOS 9.1, *)
    lazy var livePhotoView = PHLivePhotoView()
    /// 是否在播放
    private(set) var isPlaying = false
    /// 是否按压唤醒
    private var isForce = false
    /// 单击手势
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    private var liveConstraints = [NSLayoutConstraint]()
    
    
    public override func buildView() {
        super.buildView()
        
        liveBadgeImageView.backgroundColor = .clear
        liveBadgeImageView.contentMode = .scaleToFill

        liveLabel.text = "Live"
        liveLabel.font = RITLPhotoFont.regular.font(size: 14)
        liveLabel.textColor = .white
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(liveBadgeImageView)
        contentView.addSubview(liveLabel)
        
        iconImageView.ritl_photos_anchorEdge(to: contentView)
        
//        iconImageView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        liveBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        liveBadgeImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        liveBadgeImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        liveBadgeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        liveBadgeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: RITLPhotoBarDistance.navigationBar.height + 18).isActive = true
        
//        liveBadgeImageView.snp.makeConstraints { make in
//            make.height.width.equalTo(25)
//            make.leading.equalToSuperview().offset(10)
//            make.top.equalToSuperview().offset(RITLPhotoBarDistance.navigationBar.height + 18)
//        }
        
        liveLabel.translatesAutoresizingMaskIntoConstraints = false
        liveLabel.centerYAnchor.constraint(equalTo: liveBadgeImageView.centerYAnchor).isActive = true
        liveLabel.leadingAnchor.constraint(equalTo: liveBadgeImageView.trailingAnchor, constant: 3).isActive = true
//        liveLabel.snp.makeConstraints { make in
//            make.centerY.equalTo(self.liveBadgeImageView)
//            make.leading.equalTo(self.liveBadgeImageView.snp.trailing).offset(3)
//        }
        
        //单击事件
        if #available(iOS 9.1, *) {
            liveBadgeImageView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            livePhotoView.isHidden = true
            livePhotoView.delegate = self
            livePhotoView.isUserInteractionEnabled = false
            
            contentView.addSubview(livePhotoView)
            livePhotoView.translatesAutoresizingMaskIntoConstraints = false
            liveConstraints.append(livePhotoView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor))
            liveConstraints.append(livePhotoView.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor))
            NSLayoutConstraint.activate(liveConstraints)
//            livePhotoView.snp.makeConstraints { make in
//                make.center.equalTo(iconImageView)
//            }
            
            contentView.addGestureRecognizer(tapGestureRecognizer)
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.addTarget(self, action: #selector(tapGestureDidAction(tapGesture:)))
        }
    }
    
    public override func iconImageSetComplete() {
        guard let asset = asset else { return }
        if #available(iOS 9.1, *) {
            //移除所有的约束
            NSLayoutConstraint.deactivate(liveConstraints)
            liveConstraints.append(livePhotoView.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor))
            liveConstraints.append(livePhotoView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor))
            liveConstraints.append(livePhotoView.widthAnchor.constraint(equalTo: iconImageView.widthAnchor))
            liveConstraints.append(livePhotoView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)))
            NSLayoutConstraint.activate(liveConstraints)
//
//            livePhotoView.snp.remakeConstraints { make in
//                make.center.width.equalTo(iconImageView)
//                make.height.equalTo(UIScreen.main.bounds.width * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth))
//            }
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        stop()
    }
    
    @available(iOS 9.1, *)
    @objc func tapGestureDidAction(tapGesture: UITapGestureRecognizer) {
        if isPlaying { stop(); return }
        guard !isPlaying && livePhotoView.isHidden else { return }
        play()
    }
}


@available(iOS 9.1, *)
extension RITLPhotosBrowserLiveCollectionCell: PHLivePhotoViewDelegate {
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlaying = true
        livePhotoView.isHidden = false
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlaying = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.livePhotoView.isHidden = true
        }
    }
}


//let RITLPhotosBrowserVideoTapNotificationName = Notification.Name("RITLPhotosBrowserVideoTapNotificationName")
extension String {
    static let RITLPhotosBrowserVideoTapNotificationHiddenKey = "hidden"
}

//MARK: Video的图片
public class RITLPhotosBrowserVideoCollectionCell: RITLPhotosBrowserCollectionCell, RITLPhotosBrowserResetter {
    
    /// 播放的imageView
    let playerImageView = UIImageView()
    /// 播放的layer
    var player: AVPlayerLayer?
    
    public override func buildView() {
        super.buildView()
        
        playerImageView.alpha = 0.9
        playerImageView.image = RITLPhotosImage.browser_video.image
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(playerImageView)
        
        iconImageView.ritl_photos_anchorEdge(to: contentView)
//        iconImageView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        playerImageView.translatesAutoresizingMaskIntoConstraints = false
        playerImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        playerImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        playerImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        playerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//        playerImageView.snp.makeConstraints { make in
//            make.width.height.equalTo(80)
//            make.center.equalToSuperview()
//        }

        //追加点击响应
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(tapGestureDidAction(tapGesture:)))
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        guard player?.superlayer != nil else { return }
        player?.removeFromSuperlayer()
        player = nil
    }
    
    
    @objc func tapGestureDidAction(tapGesture: UITapGestureRecognizer) {
        if player == nil { play(); return }
        stop()
    }
    
    @objc func stopNotification() {
        stop()
    }
}

