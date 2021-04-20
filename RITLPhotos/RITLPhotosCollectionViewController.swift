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
    /// 所有的资源数组
    private var allAssetCollections = [[PHAssetCollection]]()
    
    /// Library
    private let photoLibrary = PHPhotoLibrary.shared()
    private let imageManager = PHCachingImageManager()
    /// 用于判断变化
    private var regularResult: PHFetchResult<PHAssetCollection>?
    private var topLevelResult: PHFetchResult<PHCollection>?
    /// 队列
    @available(iOS 10.0, *)
    private lazy var photo_queue: DispatchQueue = {
        return DispatchQueue(label: "com.ritl_photo", attributes: .concurrent)
    }()

    // Views
    private lazy var collectionView: UICollectionView = {
        //
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        collectionView.contentInset.bottom = RITLPhotoBarDistance.tabBar.normalHeight
        collectionView.bounces = true
        collectionView.backgroundView = {
            let view = UIView()
            view.backgroundColor = 50.ritl_p_color
            return view
        }()
        //注册cell
        collectionView.register(RITLPhotosCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
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
    private let groupPickerViewDataSource = RITLPhotosRowTableViewDataSource()
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
        
        bottomBar.backgroundColor = .clear
        
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
                //更新列表数据源
                let topLevelDatas = topLevelItem?.datas as? [PHAssetCollection] ?? []
                self.allAssetCollections = [regularItem.datas] + [topLevelDatas]
                //默认选择第一个
                let assetCollection = regularItem.datas.first ?? (topLevelItem?.datas.first as? PHAssetCollection) ?? PHAssetCollection()
                self.updateCollection(collection: assetCollection)
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
    
    
    /// 重置缓存
    func resetCache() {
        imageManager.stopCachingImagesForAllAssets()
    }

}


//MARK: <UICollectionViewDataSource>
extension RITLPhotosCollectionViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .purple
        guard let assets = assets else { return cell }
        
        if let cell = cell as? RITLPhotosCollectionViewCell {
            //安全判定
            guard assets.count > indexPath.item else { return cell }
            //asset
            let asset = assets.object(at: indexPath.item)
            //size
            let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
            //id
            cell.assetIdentifer = asset.localIdentifier
            //cache
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: PHImageRequestOptions()) { (image, info) in
                guard cell.assetIdentifer == asset.localIdentifier, let image = image else { return }
                cell.iconImageView.image = image
            }
        }
        
        return cell
    }
}


//MARK: <UICollectionViewDelegateFlowLayout>
extension RITLPhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size: CGFloat = (min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 3 * 3) / 4
        return CGSize(width: size, height: size)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}


//MARK: <UICollectionViewDataSourcePrefetching>
extension RITLPhotosCollectionViewController: UICollectionViewDataSourcePrefetching {
    
    @available(iOS 10.0, *)
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        //size
        let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0))
        //Cache
        photo_queue.async {
            self.imageManager.startCachingImages(for: indexPaths.compactMap { self.assets?.object(at: $0.item) }, targetSize: size, contentMode: .aspectFill, options: nil)
        }
    }
    
    @available(iOS 10.0, *)
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
        //size
        let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0))
        //Cache
        photo_queue.async {
            self.imageManager.stopCachingImages(for: indexPaths.compactMap { self.assets?.object(at: $0.item) }, targetSize: size, contentMode: .aspectFill, options: nil)
        }
    }
    
}


//MARK: <RITLPhotosNavigationItemViewDelegate>
extension RITLPhotosCollectionViewController: RITLPhotosNavigationItemViewDelegate {
    
    /// 点击需要进行动画变化以及列表展示·
    public func photosPickerViewDidTap(view: RITLPhotosNavigationItemView) {
        //
        updateTopPickerViewUI()
        //展示或者隐藏
        updatePhotosRowTableViewDisplay(isHidden: !groupPickerView.isHidden)
    }
    
    /// 更新 groupPickerView
    private func updateTopPickerViewUI() {
        //更新自己的imageView的旋转方向
        UIView.animate(withDuration: 0.2) {
            self.groupSwitchView.imageView.transform = self.groupSwitchView.imageView.transform.rotated(by: .pi)
        }
    }
    
    
    private func updateCollection(collection: PHAssetCollection) {
        //设置数据
        assetCollection = collection
        //获得所有的数据源
        assets = PHAsset.fetchAssets(in: collection, options: nil)
        //更新头部以及选择器的数据
//        groupSwitchView.titleLabel.text = collection.localizedTitle ?? ""
        groupSwitchView.updateTitle(text: collection.localizedTitle ?? "")
        //更新列表的数据源
        groupPickerViewDataSource.update(currentId: collection.localIdentifier, datas: self.allAssetCollections)
        //刷新本地的图片
        collectionView.reloadData()
    }
}


//MARK: <RITLPhotosRowTableViewDelegate>
extension RITLPhotosCollectionViewController: RITLPhotosRowTableViewDelegate {
    
    public func photosRowTableView(view: RITLPhotosRowTableView, didTap indexPath: IndexPath) {
        //更新数据
        let collection = allAssetCollections[indexPath.section][indexPath.row]
        updateCollection(collection: collection)
        //消失即可
        photosRowTableViewShouldDismiss(view: view)
    }
    
    
    public func photosRowTableViewShouldDismiss(view: RITLPhotosRowTableView) {
        //消失
        updateTopPickerViewUI()
        updatePhotosRowTableViewDisplay(isHidden: true)
    }
    
    
    
    /// 更新展示状态
    /// status: true表示启用，false表示隐藏
    private func updatePhotosRowTableViewDisplay(isHidden: Bool) {
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
