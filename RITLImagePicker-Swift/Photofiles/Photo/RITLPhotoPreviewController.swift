//
//  RITLPhotoPreviewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/22.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit
import Photos

/// 响应3D Touch的视图
class RITLPhotoPreviewController: UIViewController
{
    /// 当前显示的资源对象
    var showAsset : PHAsset = PHAsset()
    
    
    /// 展示图片的视图
    lazy fileprivate var imageView : UIImageView = {
       
        let imageView = UIImageView()
        
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 8.0
        
        return imageView
    }()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //获得资源的宽度与高度的比例
        let scale = CGFloat(showAsset.pixelHeight) * 1.0 / CGFloat(showAsset.pixelWidth)
        
        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width * scale)
        
        //添加
        view.addSubview(imageView)
        
        //约束布局
        imageView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
        
        //获取图片对象
        RITLPhotoHandleManager.asset(representionIn: showAsset, size: preferredContentSize) { (image, asset) in
            
            self.imageView.image = image
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    deinit {
        
        print("\(self.self)deinit")
    }
}
