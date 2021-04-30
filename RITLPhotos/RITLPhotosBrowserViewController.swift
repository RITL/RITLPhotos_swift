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
        case .video: return RITLPhotosBrowserNormalCollectionCell.self
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
    var popHandler: RITLPhotosBrowserWillPopHandler?
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
    /// 集合
    private lazy var collectionView: UICollectionView = {
        //flowLayout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 2 * RITLPhotosBrowserSpace
//        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: RITLPhotosBrowserSpace, bottom: 0, right: RITLPhotosBrowserSpace)
        flowLayout.itemSize = UIScreen.main.bounds.size
        //
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundView = {
            let view = UIView()
            view.backgroundColor = 50.ritl_p_color
            return view
        }()
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    convenience init(dataSource: RITLPhotosBrowserDataSource?,popHandler: RITLPhotosBrowserWillPopHandler? = nil) {
        self.init()
        self.dataSource = dataSource
        self.popHandler = popHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        //导航栏的返回
        installNavigationItem()
        
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
        
        //注册通知
        tapNotification = NotificationCenter.default.addObserver(forName: RITLPhotosBrowserTapNotificationName, object: nil, queue: OperationQueue.main) { [weak self] _ in
            //导航变换
            self?.toolBarShouldChanged()
        }
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
//            selectButton.addTarget(self, action: #selector(backItemDidTap), for: .touchUpInside)
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
    
    
    deinit {
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
    
    private func toolBarShouldChanged() {
        //导航
        let isNavigationBarHidden = navigationController?.isNavigationBarHidden ?? false
        navigationController?.setNavigationBarHidden(!isNavigationBarHidden, animated: false)
        
        //底部
        bottomBar.isHidden = !bottomBar.isHidden
    }
    
    @objc func backItemDidTap() {
        popHandler?()
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
}

extension RITLPhotosBrowserViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let resetter = cell as? RITLPhotosBrowserResetter else { return }
        resetter.reset()
    }
}
