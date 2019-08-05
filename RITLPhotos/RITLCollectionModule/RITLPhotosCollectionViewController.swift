//
//  RITLPhotosCollectionViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/8/1.
//  Copyright © 2019 YueWen. All rights reserved.
//

import UIKit
import SnapKit


///
final class RITLPhotosCollectionViewController: UIViewController {

    /// `PHCollection`的`localIdentifier`
    var localIdentifier = ""
    
    /// 展示的集合视图
    lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        
        return collectionView
    }()
    
    /// 底部的视图
    lazy var bottomView: RITLPhotosBottomView = {
        
        let bottomView = RITLPhotosBottomView()
        bottomView.previewButton.isHidden = true
        bottomView.fullButton.isSelected = false //默认不是固定的，需要根据是否点击了高清图
        
        bottomView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        return bottomView
    }()
    
    
    convenience init(localIdentifier: String) {
        self.init()
        self.localIdentifier = localIdentifier
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        
        //进行布局
        collectionView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(RITLPhotosBarDistance.TabBar.height - 3)
        }
    }
    
    
    deinit {
        print("\(type(of: self)) I am dealloc")
    }
}
