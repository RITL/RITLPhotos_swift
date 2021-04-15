//
//  RITLPhotosCollectionViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/14.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos
import SnapKit

///
public class RITLPhotosCollectionViewController: UIViewController {
    
    /// `PHCollection`的`localIdentifier`
    var localIdentifier = ""
    /// 当前展示的集合
    private var assetCollection: PHAssetCollection?
    private var assets: PHFetchResult<PHAsset>?
    
    /// Library
    private let photoLibrary = PHPhotoLibrary.shared()
    private let imageManager = PHCachingImageManager()

    // Views
    private lazy var collectionView: UICollectionView = {
        //
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundView = {
            let view = UIView()
            view.backgroundColor = 50.ritl_p_color
            return view
        }()
        
        return collectionView
    }()
    
    /// 底部的工具栏
    private let bottomBar = RITLPhotosBottomBar()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏
        //导航栏的返回
        let buttonItem = UIBarButtonItem(customView: {
            //customButton
            let backButton = UIButton()
            backButton.adjustsImageWhenHighlighted = false
            backButton.setImage(RITLPhotosImage.nav_close.image, for: .normal)
            backButton.setImage(RITLPhotosImage.nav_close.image, for: .highlighted)
            backButton.frame.size = 32.ritl_p_size
            backButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            backButton.addTarget(self, action: #selector(backItemDidTap), for: .touchUpInside)
            //customView
            let containerView = UIView()
            containerView.frame.size = 32.ritl_p_size
            containerView.addSubview(backButton)
            return containerView
        }())
        navigationItem.leftBarButtonItem = buttonItem
        //导航栏的titleView
        let titleView = UIView()
        titleView.frame.size = CGSize(width: 100, height: 40)
        navigationItem.titleView = titleView
        
        //设置UI
        view.backgroundColor = 50.ritl_p_color
        
        //追加视图
        view.addSubview(collectionView)
        view.addSubview(bottomBar)
        
        bottomBar.backgroundColor = .white
        
        collectionView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bottomBar.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(RITLPhotoBarDistance.tabBar.height)
        }
        
        //更新数据
        updateAssetCollection()
        
        //进行权限检测
        PHPhotoLibrary.authorizationCheck { (status) in
            
            self.updateAssets()
            
        } deniedHander: { (status) in
            
            print("权限未开启");
        }
    }
    

    
    @objc func backItemDidTap() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    

    /// 更新 assetCollection
    func updateAssetCollection() {
        //如果localIdentifier为空，使用默认的相册即可
        if localIdentifier == "" {
            assetCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject
        //使用localIdentifier
        } else {
            assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
        }
    }
    
    
    /// 更新所有的数据
    func updateAssets() {
        guard let assetCollection = self.assetCollection else { return }
        //更新assets
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        //获取数据
        assets = PHAsset.fetchAssets(in: assetCollection, options: options)
    }
    
    /// 重置缓存
    func resetCache() {
        imageManager.stopCachingImagesForAllAssets()
    }

}


extension RITLPhotosCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
