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
    
    /// 顶部的工具栏
    private lazy var groupSwitchView: RITLPhotosNavigationItemView = {
        return RITLPhotosNavigationItemView(frame: .zero, delegate: self)
    }()
    /// 底部的工具栏
    private let bottomBar = RITLPhotosBottomBar()
    /// 相册组的选择器
    private let groupPickerView = RITLPhotosRowTableView()
    private let groupPickerViewDataSource = RITLPhotosCollectionTableViewDataSource()
    private let groupPickerViewHeight = UIScreen.main.bounds.height - RITLPhotoBarDistance.navigationBar.height
    
    
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
//        titleView.backgroundColor = .orange
        //宽度
        let width: CGFloat = UIScreen.main.bounds.width - 54 * 2
        titleView.frame.size = CGSize(width: width, height: 44)
        navigationItem.titleView = titleView
        if (UIDevice.current.systemVersion as NSString).floatValue >= 13.0 {
            titleView.snp.makeConstraints { (make) in
                make.width.equalTo(width)
                make.height.equalTo(44)
            }
        }
        //追加导航标题
        titleView.addSubview(groupSwitchView)
        groupSwitchView.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.width.equalTo(width)
            make.top.leading.equalToSuperview()
        }
        
        //设置UI
        view.backgroundColor = 50.ritl_p_color
        groupPickerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: groupPickerViewHeight)
        groupPickerView.layer.opacity = 0.0
        groupPickerView.isHidden = true
        groupPickerView.delegate = self
        groupPickerViewDataSource.registerTableViewAndCells(tableView:  groupPickerView.tableView)
        
        //追加视图
        view.addSubview(collectionView)
        view.addSubview(bottomBar)
        view.addSubview(groupPickerView)
        
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
            //首先获得相册组
            self.photoLibrary.fetchAlbumGroups(autoSort: true, needTopLevel: true) { (regularItem, topLevelItem) in
                //如果都是空，则规避掉
                guard regularItem.datas.count + (topLevelItem?.data?.count ?? 0) > 0 else { return }
                //默认选择第一个
                let assetCollection = regularItem.datas.first ?? (topLevelItem?.datas.first as? PHAssetCollection) ?? PHAssetCollection()
                self.assetCollection = assetCollection
                //获得所有的数据源
                self.assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
                //更新头部以及选择器的数据
                self.groupSwitchView.titleLabel.text = self.assetCollection?.localizedTitle ?? ""
                //更新列表数据源
                let topLevelDatas = topLevelItem?.datas as? [PHAssetCollection] ?? []
                self.groupPickerViewDataSource.update(currentId: assetCollection.localIdentifier, datas: [regularItem.datas] + [topLevelDatas])
                //刷新本地的图片
                self.collectionView.reloadData()
            }
            
        } deniedHander: { (status) in
            
            print("权限未开启");
        }
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// 展开
//        updatePhotosCollectionTableViewDisplay(isHidden: false)
    }
    

    deinit {
        print("\(type(of: self)) is deinit")
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
    
    
//    /// 更新所有的数据
//    func updateAssets() {
//
//        guard let assetCollection = self.assetCollection else { return }
//        //更新assets
//        let options = PHFetchOptions()
//        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        //获取数据
//        assets = PHAsset.fetchAssets(in: assetCollection, options: options)
//    }
    
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


extension RITLPhotosCollectionViewController: RITLPhotosNavigationItemViewDelegate {
    
    /// 点击需要进行动画变化以及列表展示·
    public func photosPickerViewDidTap(view: RITLPhotosNavigationItemView) {
        //
        updateTopPickerViewUI()
        //展示或者隐藏
        updatePhotosCollectionTableViewDisplay(isHidden: !groupPickerView.isHidden)
    }
    
    /// 更新 groupPickerView
    private func updateTopPickerViewUI() {
        //更新自己的imageView的旋转方向
        UIView.animate(withDuration: 0.2) {
            self.groupSwitchView.imageView.transform = self.groupSwitchView.imageView.transform.rotated(by: .pi)
        }
    }
}



extension RITLPhotosCollectionViewController: RITLPhotosRowTableViewDelegate {
    
    public func photosCollectionTableViewShouldDismiss(view: RITLPhotosRowTableView) {
        //消失
        updateTopPickerViewUI()
        updatePhotosCollectionTableViewDisplay(isHidden: true)
    }
    
    /// 更新数据
    private func updatePhotosCollectionTableViewData() {
        
    }
    
    /// 更新展示状态
    /// status: true表示启用，false表示隐藏
    private func updatePhotosCollectionTableViewDisplay(isHidden: Bool) {
        //只有状态不同才会响应
        guard isHidden != groupPickerView.isHidden else { return }
        //率先将状态修改
        //如果是显示优先显示即可
        if !isHidden {
            self.groupPickerView.isHidden = isHidden
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {

            self.groupPickerView.layer.opacity = isHidden ? 0 : 1
            self.groupPickerView.updateTableViewFrame(isFold: isHidden)

        } completion: { (_) in

            guard isHidden else { return }
            self.groupPickerView.isHidden = isHidden
        }
    }
}
