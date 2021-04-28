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


fileprivate extension RITLPhotosCollectionCellType {
    
    var cellClass: AnyClass {
        switch self {
        case .video: return RITLPhotosVideoCollectionCell.self
        case .live: return RITLPhotosLiveCollectionCell.self
        case .photo: return RITLPhotosNormalCollectionCell.self
        default: return RITLPhotosCollectionViewCell.self
        }
    }
}


///
public class RITLPhotosCollectionViewController: UIViewController {
    
    /// `PHCollection`的`localIdentifier`
    var localIdentifier = ""
    
    /// Library
    private let photoLibrary = PHPhotoLibrary.shared()
    private let imageManager = PHCachingImageManager()
    //DataManager
    private let dataManager = RITLPhotosDataManager.shareInstance()
    private var countObservation: NSKeyValueObservation?
    private var isHightQualityObservation: NSKeyValueObservation?
    private var photoMaker = RITLPhotosMaker.shareInstance()
    private var photoConfiguration = RITLPhotosConfigation.default()
    
    /// 当前展示的集合
    private var assetCollection: PHAssetCollection?
    private var assets: PHFetchResult<PHAsset>?

    /// 用于判断变化
    private var regularResult: PHFetchResult<PHAssetCollection>?
    private var topLevelResult: PHFetchResult<PHCollection>?
    
    /// 所有的资源数组
    private var allAssetCollections = [[PHAssetCollection]]()
    
    /// 队列
    @available(iOS 10.0, *)
    private lazy var photo_queue: DispatchQueue = {
        return DispatchQueue(label: "com.ritl_photo", attributes: .concurrent)
    }()
    /// iOS10之后不再使用
    private var previousPreheatRect: CGRect = .zero

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
        for type in RITLPhotosCollectionCellType.allCases {
            collectionView.register(type.cellClass, forCellWithReuseIdentifier: type.rawValue)
        }

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
        let width: CGFloat = UIScreen.main.bounds.width - 60 * 2
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
        groupPickerView.frame = CGRect(x: 0, y: RITLPhotoBarDistance.navigationBar.height, width: view.bounds.width, height: groupPickerViewHeight)
        groupPickerView.layer.opacity = 0.0
        groupPickerView.isHidden = true
        groupPickerView.delegate = self
        groupPickerViewDataSource.registerTableViewAndCells(tableView:  groupPickerView.tableView)
        
        //追加视图
        view.addSubview(collectionView)
        view.addSubview(bottomBar)
        view.addSubview(groupPickerView)
        
        bottomBar.backgroundColor = .clear
        bottomBar.highButton.addTarget(self, action: #selector(highButtonDidTap), for: .touchUpInside)
        bottomBar.sendButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        bottomBar.previewButton.addTarget(self, action: #selector(previewButtonDidTap), for: .touchUpInside)
        
        
        collectionView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bottomBar.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(RITLPhotoBarDistance.tabBar.height)
        }
        
        //设置KVO
        countObservation = dataManager.observe(\.count, options: .new) { [weak self] (_, _) in
            self?.updateBottomSendButton()
        }
        
        isHightQualityObservation = dataManager.observe(\.isHightQuality, options: .new, changeHandler: { [weak self] (_, change) in
            let isHight = change.newValue ?? false
            self?.bottomBar.highButton.isSelected = isHight
        })
        
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
        //如果低于iOS10 启用自己的优化方案
        if (UIDevice.current.systemVersion as NSString).floatValue < 10.0 {
            updateCachedAsset()
        }
    }
    

    deinit {
        countObservation = nil
        isHightQualityObservation = nil
        print("\(type(of: self)) is deinit")
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
    
    /// 底部发送按钮状态
    private func updateBottomSendButton() {
        let isEmpty = dataManager.count <= 0
        bottomBar.previewButton.isEnabled = !isEmpty
        let title = "发送\(isEmpty ? "" : "(\(dataManager.count))")"
        let state: UIControl.State = isEmpty ? .disabled : .normal
        bottomBar.sendButton.setTitle(title, for: state)
        bottomBar.sendButton.isEnabled = !isEmpty
    }
    
    @objc func highButtonDidTap() {
        updateStateBottomHighButton()
    }
    
    @objc func sendButtonDidTap() {
        photoMaker.startMake {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func previewButtonDidTap() {
        pushToRITLPhotosBrowserViewController(isAll: false)
    }
    
    @objc func backItemDidTap() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    

    /// 底部高清状态
    private func updateStateBottomHighButton() {
        dataManager.isHightQuality = !dataManager.isHightQuality
    }
    
    
    private func pushToRITLPhotosBrowserViewController(isAll: Bool, currentAsset: PHAsset? = nil) {
        let viewController = RITLPhotosBrowserViewController()
        viewController.dataSource = isAll ? {
            //所有的数据源
            let dataSource = RITLPhotosBrowserAllDataSource()
            if let assetCollection = assetCollection {
                dataSource.collection = assetCollection
            }
            if let currentAsset = currentAsset {
                dataSource.asset = currentAsset
            }
            return dataSource
        }() : nil
        navigationController?.pushViewController(viewController, animated: true)
    }
}


//MARK: <UICollectionViewDataSource>
extension RITLPhotosCollectionViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //安全判定
        guard let assets = assets, assets.count > indexPath.item else { return UICollectionViewCell() }
        //asset
        let asset = assets.object(at: indexPath.item)
        //获得cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: asset.cellIdentifier().rawValue, for: indexPath)
        if let cell = cell as? RITLPhotosCollectionViewCell {
            //size
            var size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
            size.width *= UIScreen.main.scale
            size.height *= UIScreen.main.scale
            cell.assetIdentifer = asset.localIdentifier
            //cache
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: PHImageRequestOptions()) { (image, info) in
                guard cell.assetIdentifer == asset.localIdentifier, let image = image else { return }
                cell.delegate = self
                cell.asset =  asset
                cell.indexPath = indexPath
                cell.iconImageView.image = image
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //asset
        guard let asset = assets?.object(at: indexPath.item) else { return }
        //是否选中
        let isSelected = dataManager.assetIdentifers.contains(asset.localIdentifier)
        //进行划分
        if let cell = cell as? RITLPhotosCollectionViewCell {
            cell.indexLabel.isHidden = !isSelected
            //如果选中
            if isSelected {
                cell.indexLabel.text = "\((dataManager.assetIdentifers.firstIndex(of: asset.localIdentifier) ?? 0) + 1)"
            }
        }
        /// 视频样式
        if let cell = cell as? RITLPhotosVideoCollectionCell {
            //设置时间显示
            cell.messageLabel.text = asset.duration.toString()
        }
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
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushToRITLPhotosBrowserViewController(isAll: true, currentAsset: assets?[indexPath.item])
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
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //如果低于iOS10 启用自己的优化方案
        if (UIDevice.current.systemVersion as NSString).floatValue < 10.0 {
            updateCachedAsset()
        }
    }
}


//MARK: <RITLPhotosCollectionCellActionTarget>
extension RITLPhotosCollectionViewController: RITLPhotosCollectionCellActionTarget {
    
    public func photosCollectionCell(selectedDidTap cell: RITLPhotosCollectionViewCell, complete: RITLPhotosCellStatusAction?) {
        //获取asset
        guard let asset = cell.asset else { return } //不进行选择
        //如果大于最大限制
        if dataManager.count >= photoConfiguration.maxCount && !dataManager.contain(asset: asset) {
            return
        }
        //获得各项参数
        let index = dataManager.addOrRemove(asset: asset)
        //执行回调
        complete?(.permit, index > 0, max(0, index))
        //如果是取消操作，刷新界面
        guard index < 0 else { return }
        collectionView.reloadData()
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
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(in: collection, options: options)
        //更新头部以及选择器的数据
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
        //如果存在数据
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
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

//MARK: Cache
//iOS10之前需要进行手动计算，iOS10之后使用 UICollectionViewDataSourcePrefetching
fileprivate extension RITLPhotosCollectionViewController {
    
    
    @available(iOS, deprecated: 10.0, message: "iOS 10 Use collectionView:prefetchItemsAtIndexPaths: and collectionView:cancelPrefetchingForItemsAtIndexPaths: instead.")
    func updateCachedAsset() {
        
        guard isViewLoaded && view.window != nil else { return }
        //没有权限关闭即可
        guard PHPhotoLibrary.authorizationStatus() != .authorized else { return }

        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        //进行拓展
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)

        //只有可视化的区域与之前有显著的区域变化才需要更新
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }

        //进行提前缓存的资源
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        //进行添加的
        let addedAssets = addedRects
            .flatMap { rect in self.collectionView.ritl_p_indexPathsForElements(in: rect) }
            .compactMap { indexPath in self.assets?.object(at: indexPath.item) }
        
        let removedAssets = removedRects
            .flatMap { rect in collectionView.ritl_p_indexPathsForElements(in: rect) }
            .compactMap { indexPath in self.assets?.object(at: indexPath.item) }

        let thumbnailSize = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0))
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
            targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
            targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)

        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }

    @available(iOS, deprecated: 10.0, message: "iOS 10 Use collectionView:prefetchItemsAtIndexPaths: and collectionView:cancelPrefetchingForItemsAtIndexPaths: instead.")
    func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            //表示上拉
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                    width: new.width, height: new.maxY - old.maxY)]
            }
            //表示下拉
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                    width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            //表示下拉
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                      width: new.width, height: old.maxY - new.maxY)]
            }
            //表示上拉
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                      width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}


private extension TimeInterval {
    /// 转换格式
    func toString() -> String {
        let time = Int(self)
        // 大于小时
        if time >= 60 * 60 {
            return "\((time / 60 / 60).format()): \((time % 3600 / 60).format()):\((time % 3600 % 60).format())"
        }
        // 大于分钟
        if time >= 60 {
            return "\((time / 60).format()):\((time % 60).format())"
        }
        
        return "00:\(time.format())"
    }
}


fileprivate extension Int {
    
    func format() -> String {
        return String.p_format(number: self)
    }
}

private extension String {
    
    //固定的转成2位的Int类型字符串
    static func p_format(number: Int) -> String {
        return String(format: "%0.2d", number)
    }
}
