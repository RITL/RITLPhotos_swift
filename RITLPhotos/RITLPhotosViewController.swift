//
//  RITLPhotosViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/14.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos


extension Notification.Name {
    
    /// 回调通知
    static let RITLPhotosWillDismissNotificationName = Notification.Name("RITLPhotosWillDismissNotificationName")
}


public protocol RITLPhotosViewControllerDelegate: AnyObject {
    
    
    /// 即将消失的回调
    /// - Parameter viewController: RITLPhotosViewController
    func photosViewControllerWillDismiss(viewController: UIViewController)

    /// 获取权限失败的回调
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - denied: 获取权限失败的权限
    func photosViewController(viewController: UIViewController, authorization denied: PHAuthorizationStatus)

    /// 选中图片以及视频等资源的本地identifer
    /// 可通过本次的回调，填出二次选择时设置默认选好的资源
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - identifiers: 选中资源的identifier
    func photosViewController(viewController: UIViewController, assetIdentifiers identifiers: [String])


    /// 选中图片以及视频等资源的默认缩略图
    /// 根据thumbnailSize设置所得，
    /// `如果thumbnailSize为.Zero,则不进行回调`
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - thumbnailImages: 选中资源的缩略图
    ///   - infos: 选中图片的缩略图信息
    func photosViewController(viewController: UIViewController, thumbnailImages: [UIImage], infos: [[AnyHashable : Any]])


    /// 选中图片以及视频等资源的数据
    /// 根据是否选中原图所得
    /// 如果为原图，则返回原图大小的数据
    /// 如果不是原图，则返回原始比例的数据
    /// 注: 不会返回thumbnailImages的数据大小
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - datas: 选中资源的Data类型
    ///   - infos: 选中图片的额外信息
    func photosViewController(viewController: UIViewController, datas: [Data], infos: [[AnyHashable : Any]])


    /// 选中图片以及视频等资源的源资源对象
    /// 如果需要使用源资源对象进行相关操作,可以通过该方法拿到数据
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - assets: 选中的PHAsset对象
    func photosViewController(viewController: UIViewController, assets: [PHAsset])
    
    

    /// 选中的图片中包含已经由于外部相册删除或者其他原因导致加载失败的资源对象
    /// 删除后不在其他的回调中进行回调
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - datas: 数据，包含被删除资源的原有资源对象，被删除资源的原有id，被删除资源的原有排序以及可能存在的信息
    func photosViewController(viewController: UIViewController, fail datas: [(asset: PHAsset, id: String, index: Int, info: [AnyHashable: Any]?)])
}


public extension RITLPhotosViewControllerDelegate {
    
    func photosViewControllerWillDismiss(viewController: UIViewController) {}
    func photosViewController(viewController: UIViewController, assetIdentifiers identifiers: [String]) {}
    func photosViewController(viewController: UIViewController, thumbnailImages: [UIImage], infos: [[AnyHashable : Any]]){}
    func photosViewController(viewController: UIViewController, datas: [Data], infos: [[AnyHashable : Any]]) {}
    func photosViewController(viewController: UIViewController, assets: [PHAsset]) {}
    func photosViewController(viewController: UIViewController, authorization denied: PHAuthorizationStatus) {}
    func photosViewController(viewController: UIViewController, fail datas: [(asset: PHAsset, id: String, index: Int, info: [AnyHashable: Any]?)]) {}
}


/// 图片控制器
public class RITLPhotosViewController: UINavigationController {
    
    /// 代理对象
    public weak var photo_delegate: RITLPhotosViewControllerDelegate? {
        didSet {
            maker.delegate = photo_delegate
            maker.bindViewController = self
        }
    }
    
    /// 缩略图的大小，默认为.zero
    public var thumbnailSize: CGSize = .zero {
        didSet {
            maker.thumbnailSize = thumbnailSize
        }
    }
    
    /// 默认选中的资源的id
    public var defaultIdentifiers = [String]() {
        didSet {
            dataManager.defaultIdentifiers = defaultIdentifiers
        }
    }

    
    ///
    private let maker = RITLPhotosMaker.shareInstance()
    private let dataManager = RITLPhotosDataManager.shareInstance()
    private var shouldReload = false
    
    /// 配置
    public let configuration = RITLPhotosConfigation.default()
    
    
    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        initPhotosViewController()
    }
    
    private override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        initPhotosViewController()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initPhotosViewController()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard shouldReload else { self.shouldReload = true; return }
        guard let viewController = viewControllers.first as? RITLPhotosCollectionViewController else { return }
        viewController.updateAllData(resetPosition: true)
    }
    
    private func initPhotosViewController() {
        modalPresentationStyle = .fullScreen
        viewControllers = [RITLPhotosCollectionViewController()]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBar.barTintColor = 35.ritl_p_color.withAlphaComponent(0.9)
        navigationBar.isTranslucent = true
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
    
    /// 目前只支持普通方向
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
