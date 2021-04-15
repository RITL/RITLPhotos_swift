//
//  RITLPhotosViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/14.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

protocol RITLPhotosViewControllerDelegate: class {
    
    
    /// 即将消失的回调
    /// - Parameter viewController: RITLPhotosViewController
    func photosViewControllerWillDismiss(viewController: UIViewController);
    
    
    /// 选中图片以及视频等资源的本地identifer
    /// 可通过本次的回调，填出二次选择时设置默认选好的资源
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - identifiers: 选中资源的identifier
    func photosViewController(viewController: UIViewController, assetIdentifiers identifiers: [String])
    
    
    /// 选中图片以及视频等资源的默认缩略图
    /// 根据thumbnailSize设置所得，如果thumbnailSize为.Zero,则不进行回调
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - thumbnailImages: 选中资源的缩略图
    ///   - infos: 选中图片的缩略图信息
    func photosViewController(viewController: UIViewController, thumbnailImages: [UIImage], infos: [[String: Any]])
    
    
    /// 选中图片以及视频等资源的数据
    /// 根据是否选中原图所得
    /// 如果为原图，则返回原图大小的数据
    /// 如果不是原图，则返回原始比例的数据
    /// 注: 不会返回thumbnailImages的数据大小
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - datas: 选中资源的Data类型
    func photosViewController(viewController: UIViewController, datas: [Data])
    
    
    /// 选中图片以及视频等资源的源资源对象
    /// 如果需要使用源资源对象进行相关操作,可以通过该方法拿到数据
    /// - Parameters:
    ///   - viewController: RITLPhotosViewController
    ///   - assets: 选中的PHAsset对象
    func photosViewController(viewController: UIViewController, assets: [PHAsset])
    
}

/// 图片控制器
public class RITLPhotosViewController: UINavigationController {
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        initPhotosViewController()
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
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
    
    private func initPhotosViewController() {
        modalPresentationStyle = .fullScreen
        viewControllers = [RITLPhotosCollectionViewController()]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBar.setBackgroundImage(35.ritl_p_image, for: .default)
        navigationBar.shadowImage = 35.ritl_p_image
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
