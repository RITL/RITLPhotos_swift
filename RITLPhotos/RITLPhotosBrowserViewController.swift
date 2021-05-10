//
//  RITLPhotosBrowserViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/27.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

/// 浏览器的自定义数据源
protocol RITLPhotosBrowserDataSource: UICollectionViewDataSource {
    
    /// 请求图片的对象
    var imageManager: PHCachingImageManager { get }
    /// 默认第一次显示的item
    func defaultIndexPath() -> IndexPath
    /// 获得该位置的资源对象
    func asset(at indexPath: IndexPath) -> PHAsset?
    /// 用于对collectionView进行操作
    func update(collectionView: UICollectionView)
}

extension RITLPhotosBrowserDataSource {
    
    func defaultIndexPath() -> IndexPath {
        return IndexPath(item: 0, section: 0)
    }
    
    func update(collectionView: UICollectionView) {
        //默认对响应的数据进行注册
        for type in RITLPhotosCollectionCellType.allCases {
            collectionView.register(type.cellClass, forCellWithReuseIdentifier: type.rawValue)
        }
    }
}

fileprivate extension RITLPhotosCollectionCellType {
    
    var cellClass: AnyClass {
        switch self {
        case .video: return RITLPhotosBrowserVideoCollectionCell.self
        case .live: return RITLPhotosBrowserLiveCollectionCell.self
        case .photo: return RITLPhotosBrowserNormalCollectionCell.self
        default: return RITLPhotosBrowserNormalCollectionCell.self
        }
    }
}


typealias RITLPhotosBrowserWillPopHandler = ()->()

private let RITLPhotosBrowserSpace: CGFloat = 3

/// 浏览器
final class RITLPhotosBrowserViewController: UIViewController {
    
    /// 点击返回进行的回调，用于刷新
    var disappearHandler: RITLPhotosBrowserWillPopHandler?
    /// 数据源
    var dataSource: RITLPhotosBrowserDataSource? {
        didSet {
            dataSource?.update(collectionView: collectionView)
        }
    }
    
    //dataManager
    private let dataManager = RITLPhotosDataManager.shareInstance()
    private var countObservation: NSKeyValueObservation?
    private var isHightQualityObservation: NSKeyValueObservation?
    private var tapNotification: NSObjectProtocol?
    
    /// 顶部未选中的按钮
    private var topSelectButton: UIButton!
    /// 顶部选中后的indexLabel
    private var topIndexLabel: UILabel!
    /// 底部的工具栏
    private let bottomBar = RITLPhotosBottomBar()
    private lazy var bottomBarInfiniteFrame: CGRect = {
        return CGRect(x: 0, y: view.bounds.height - RITLPhotoBarDistance.tabBar.height, width: view.bounds.width, height: RITLPhotoBarDistance.tabBar.height)
    }()
    /// 底部的处理view
    private lazy var operatingView: RITLPhotosBrowserOperatingView = {
        let operatingView = RITLPhotosBrowserOperatingView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        return operatingView
    }()
    /// 集合
    private lazy var collectionView: UICollectionView = {
        //flowLayout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 2 * RITLPhotosBrowserSpace
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: RITLPhotosBrowserSpace, bottom: 0, right: RITLPhotosBrowserSpace)
        flowLayout.itemSize = UIScreen.main.bounds.size
        //
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundView = {
            let view = UIView()
            view.backgroundColor = .black
            return view
        }()
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    /// 用于iOS10计算
    private var previousPreheatRect: CGRect = .zero
    
    convenience init(dataSource: RITLPhotosBrowserDataSource?,popHandler: RITLPhotosBrowserWillPopHandler? = nil) {
        self.init()
        self.dataSource = dataSource
        self.disappearHandler = popHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        //导航栏的返回
        installNavigationItem()
        
        /// 涉及后续的变换，采用frame
        bottomBar.frame = bottomBarInfiniteFrame
        bottomBar.updateToolBackgroundColor(color: 35.ritl_p_color.withAlphaComponent(0.5))
        bottomBar.previewButton.isHidden = true
        updateBottomSendButton()
        bottomBar.highButton.isSelected = dataManager.isHightQuality
        bottomBar.highButton.addTarget(self, action: #selector(highButtonDidTap), for: .touchUpInside)
        bottomBar.sendButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        
        //设置代理
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(collectionView)
        view.addSubview(bottomBar)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(-1 * RITLPhotosBrowserSpace)
            make.trailing.equalToSuperview().offset(RITLPhotosBrowserSpace)
        }
        
        
        //设置KVO
        countObservation = dataManager.observe(\.count, options: .new) { [weak self] (_, _) in
            self?.updateBottomSendButton()
            self?.updateOperatingView()
        }
        
        isHightQualityObservation = dataManager.observe(\.isHightQuality, options: .new, changeHandler: { [weak self] (_, change) in
            let isHight = change.newValue ?? false
            self?.bottomBar.highButton.isSelected = isHight
        })
        
        //注册通知
        tapNotification = NotificationCenter.default.addObserver(forName: RITLPhotosBrowserTapNotificationName, object: nil, queue: OperationQueue.main) { [weak self] notification in
            //导航变换
            self?.toolBarShouldChanged(isHidden: notification.userInfo?[String.RITLPhotosBrowserVideoTapNotificationHiddenKey] as? Bool)
        }
        //更新底部的视图
        updateOperatingView()
        //存在默认方法滚动即可
        guard let dataSource = dataSource else { return }
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: dataSource.defaultIndexPath(), at: .right, animated: false)
        }
        //更新顶部的标记
        updateTopSelectedControl(asset: dataSource.asset(at: dataSource.defaultIndexPath()), animated: false)
        //更新底部的预览
        updateOperating(asset: dataSource.asset(at: dataSource.defaultIndexPath()), reload: false)
    }
    
    
    /// 装载导航栏
    private func installNavigationItem() {
        
        let buttonItem = UIBarButtonItem(customView: {
            //customButton
            let backButton = UIButton()
            backButton.adjustsImageWhenHighlighted = false
            backButton.setImage(RITLPhotosImage.nav_back.image, for: .normal)
            backButton.setImage(RITLPhotosImage.nav_back.image, for: .highlighted)
            backButton.frame.size = 32.ritl_p_size
            backButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 5, bottom: 6, right: 8)
            backButton.addTarget(self, action: #selector(backItemDidTap), for: .touchUpInside)
            //customView
            let containerView = UIView()
            containerView.frame.size = 32.ritl_p_size
            containerView.addSubview(backButton)
            return containerView
        }())
        navigationItem.leftBarButtonItem = buttonItem
        
        //右侧的buttonItem
        let selectItem = UIBarButtonItem(customView: {
            //customButton
            let selectButton = UIButton()
            selectButton.adjustsImageWhenHighlighted = false
            selectButton.setImage(RITLPhotosImage.nav_deselect.image, for: .normal)
            selectButton.setImage(RITLPhotosImage.nav_deselect.image, for: .highlighted)
            selectButton.frame.size = 32.ritl_p_size
            selectButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            selectButton.addTarget(self, action: #selector(statusButtonDidTap), for: .touchUpInside)
            self.topSelectButton = selectButton
            
            //indexLabel
            let indexLabel = UILabel()
            indexLabel.font = RITLPhotoFont.regular.font(size: 16)
            indexLabel.frame.size = CGSize(width: 30, height: 30)
            indexLabel.center = CGPoint(x: 16, y: 16)
            indexLabel.textAlignment = .center
            indexLabel.textColor = .white
            indexLabel.layer.cornerRadius = 16
            indexLabel.clipsToBounds = true
            indexLabel.backgroundColor = #colorLiteral(red: 0.03529411765, green: 0.7333333333, blue: 0.3529411765, alpha: 1)
            indexLabel.isHidden = true //默认为隐藏状态
            self.topIndexLabel = indexLabel
            
            //customView
            let containerView = UIView()
            containerView.frame.size = 32.ritl_p_size
            containerView.addSubview(selectButton)
            containerView.addSubview(indexLabel)
            return containerView
        }())
        navigationItem.rightBarButtonItem = selectItem
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //如果低于iOS10 启用自己的优化方案
        if (UIDevice.current.systemVersion as NSString).floatValue < 10.0 {
            updateCachedAsset()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
        countObservation = nil
        isHightQualityObservation = nil
        guard isViewLoaded else { return }
        NotificationCenter.default.removeObserver(tapNotification!)
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
    
    /// 更新底部的操作视图
    private func updateOperatingView() {
        //如果是隐藏栏，同时隐藏
        if bottomBar.isHidden { return }
        //是否需要隐藏
        let isHidden = (dataManager.count <= 0)
        let isChanged = operatingView.isHidden == isHidden
        //不存在选中图片，隐藏即可
        operatingView.isHidden = isHidden
        //重置frame
        if isChanged {
            let operatingViewHeight = operatingView.bounds.height
            bottomBar.frame = isHidden ? bottomBarInfiniteFrame : bottomBarInfiniteFrame.inset(by: UIEdgeInsets(top: -operatingViewHeight, left: 0, bottom: 0, right: 0))
        }
        //
        if operatingView.superview == nil {
            bottomBar.addSubview(operatingView)
            operatingView.frame.origin = CGPoint(x: 0, y: 0)
        }
    }
    
    
    private func toolBarShouldChanged(isHidden: Bool? = nil) {
        //自主控制
        if let isHidden = isHidden {
            navigationController?.setNavigationBarHidden(isHidden, animated: false)
            bottomBar.isHidden = isHidden
            updateOperatingView(); return
        }
        //默认即可
        let isNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        navigationController?.setNavigationBarHidden(!isNavigationBarHidden, animated: false)
        //底部
        bottomBar.isHidden = !bottomBar.isHidden
        updateOperatingView()
    }
    
    /// 更新顶部的选中标记
    private func updateTopSelectedControl(asset: PHAsset?, animated: Bool) {
        //获得资源
        guard let asset = asset else { return }
        //底部的原图视频将隐藏
        bottomBar.highButton.isHidden = asset.mediaType == .video
        //不支持视频，则全部隐藏
        if asset.mediaType == .video && !RITLPhotosConfigation.default().isSupportVideo {
            topIndexLabel.isHidden = true
            topSelectButton.isHidden = true
            return
        }
        //是否选中
        let isSelected = dataManager.contain(asset: asset)
        //如果没有选中直接隐藏即可
        guard isSelected else {
            self.topIndexLabel.isHidden = true
            self.topSelectButton.isHidden = false
            return
        }
        //获得index
        guard let index = dataManager.assetIdentifers.firstIndex(of: asset.localIdentifier) else { return }
        //没有隐藏 或者 不使用动画 ，直接更新数据即可 或者
        if (!topIndexLabel.isHidden || !animated) {
            topIndexLabel.text = "\(index + 1)"
            topIndexLabel.isHidden = !isSelected
        }
        //如果使用动画
        else if (animated) {
            //选中的
            topIndexLabel.text = "\(index + 1)"
            topIndexLabel.isHidden = !isSelected
            //执行动画
            UIView.animate(withDuration: 0.15) {
                //放大
                self.topIndexLabel.transform = self.topIndexLabel.transform.scaledBy(x: 1.3, y: 1.3)
                
            } completion: { (_) in
                //缩小
                UIView.animate(withDuration: 0.1) {
                    self.topIndexLabel.transform = .identity
                }
            }
        }
        topSelectButton.isHidden = false
    }
    
    /// 更新底部的排版
    private func updateOperating(asset: PHAsset?, reload: Bool) {
        guard let asset = asset else { return }
        operatingView.dataSource.select(asset: asset, reload: reload)
    }
    
    private func resetCached() {
        previousPreheatRect = .zero
        dataSource?.imageManager.stopCachingImagesForAllAssets()
    }
    
    @objc func backItemDidTap() {
        disappearHandler?()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func highButtonDidTap() {
        dataManager.isHightQuality = !dataManager.isHightQuality
    }
    
    @objc func sendButtonDidTap() {
        RITLPhotosMaker.shareInstance().startMake {
            //需要停止播放即可
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func statusButtonDidTap() {
        //获得资源
        guard let asset = dataSource?.asset(at: IndexPath(item: index(collectionView), section: 0)) else { return }
        //如果是添加,针对最大的数量进行限制
        if !dataManager.contain(asset: asset), dataManager.count >= RITLPhotosConfigation.default().maxCount {
            return
        }
        //修改数据
        dataManager.addOrRemove(asset: asset)
        //更新顶部即可
        updateTopSelectedControl(asset: asset, animated: true)
    }
}


//MARK: <UICollectionViewDelegate>
extension RITLPhotosBrowserViewController: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /// 计算当前的位置
        func adjustScrollIndex() {
            
            let index = index(scrollView)
            //获得资源
            guard let asset = dataSource?.asset(at: IndexPath(item: index, section: 0)) else { return }
            //更新顶部即可
            updateTopSelectedControl(asset: asset, animated: false)
            updateOperating(asset: asset, reload: true)
        }
        
        
        if (UIDevice.current.systemVersion as NSString).floatValue < 10.0 {
            updateCachedAsset()
        }
        for updater in (collectionView.visibleCells.compactMap { $0 as? RITLPhotosBrowserUpdater }) {
            updater.stop()
        }
        //计算
        adjustScrollIndex()
    }
    
    /// 获得当前的index
    private func index(_ scrollView: UIScrollView) -> Int {
        //获得当前的index
        let contentOffsetX = min(scrollView.contentSize.width, max(0, scrollView.contentOffset.x))
        let space: CGFloat = 2 * RITLPhotosBrowserSpace
        return Int(roundf(Float(contentOffsetX + space) / Float(space + UIScreen.main.bounds.width)))
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let resetter = cell as? RITLPhotosBrowserResetter else { return }
        resetter.reset()
    }
}



//MARK: Cache
//iOS10之前需要进行手动计算，iOS10之后使用 UICollectionViewDataSourcePrefetching
extension RITLPhotosBrowserViewController {
    
    @available(iOS, deprecated: 10.0, message: "iOS 10 Use collectionView:prefetchItemsAtIndexPaths: and collectionView:cancelPrefetchingForItemsAtIndexPaths: instead.")
    private func updateCachedAsset() {
        
        if (!isViewLoaded || view.window == nil) { return; }
        
        //可视化
        let visibleRect = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y, width: collectionView.bounds.width, height: collectionView.bounds.height)
        
        //进行拓展
        let preheatRect = visibleRect.insetBy(dx: -0.5 * visibleRect.width, dy: 0)
        
        //只有可视化的区域与之前的区域有显著的区域变化才需要更新
        let delta = abs(preheatRect.midX - previousPreheatRect.midX)
        guard delta > (view.bounds.width / 3.0) else { return }
        
        //获得比较后需要进行预加载以及需要停止缓存的区域
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        
        ///进行提前缓存的资源
        let addedAssets = addedRects
            .flatMap { rect in self.collectionView.ritl_p_indexPathsForElements(in: rect) }
            .compactMap { indexPath in self.dataSource?.asset(at: indexPath) }
        
        ///提前停止缓存的资源
        let removedAssets = removedRects
            .flatMap { rect in collectionView.ritl_p_indexPathsForElements(in: rect) }
            .compactMap { indexPath in self.dataSource?.asset(at: indexPath) }
        
        let thimbnailSize = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? UIScreen.main.bounds.size
        
        //更新缓存
        dataSource?.imageManager.startCachingImages(for: addedAssets, targetSize: thimbnailSize, contentMode: .aspectFill, options: nil)
        dataSource?.imageManager.stopCachingImages(for: removedAssets, targetSize: thimbnailSize, contentMode: .aspectFill, options: nil)
        
        //记录当前位置
        previousPreheatRect = preheatRect;
    }
    
    @available(iOS, deprecated: 10.0, message: "iOS 10 Use collectionView:prefetchItemsAtIndexPaths: and collectionView:cancelPrefetchingForItemsAtIndexPaths: instead.")
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        
        if (old.intersects(new)) {//如果区域交叉
            
            var added = [CGRect]()
            if (new.maxX > old.maxX) {//表示左滑
                added.append(CGRect(x: old.maxX, y: new.origin.y, width: new.maxX - old.maxX, height: new.height))
            }
            if(old.minX > new.minX){//表示右滑
                added.append(CGRect(x: new.minX, y: new.origin.y, width: old.minX - new.minX, height: new.height))
            }
            
            var removed = [CGRect]()
            if (new.maxX < old.maxX) {//表示右滑
                removed.append(CGRect(x: new.minX, y: new.origin.y, width: old.maxX - new.maxX, height: new.height))
            }
            if (old.minX < new.minX) {//表示左滑
                removed.append(CGRect(x: new.minX, y: new.origin.y, width: new.minX - old.minX, height: new.size.height))
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}
