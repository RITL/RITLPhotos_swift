//
//  RITLPhotosMaker.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/26.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

/// 生成图片
public final class RITLPhotosMaker: NSObject {
    
    /// 局部单例
    private static weak var instance: RITLPhotosMaker?
    /// 用于处理图片的manager
    private lazy var imageManager: PHImageManager = {
       return PHImageManager()
    }()
    
    /// 真正的代理对象
    weak var delegate: RITLPhotosViewControllerDelegate?
    /// 用于绑定执行方法的viewController
    weak var bindViewController: UIViewController?
    /// 缩略图大小
    var thumbnailSize = CGSize.zero
    
    private var willDismissObserver: NSObjectProtocol?
    
    /// 局部单例
    static func shareInstance() -> RITLPhotosMaker {
        var strongInstance = instance
        objc_sync_enter(self)
        if strongInstance == nil {
            strongInstance = RITLPhotosMaker()
            instance = strongInstance
        }
        objc_sync_exit(self)
        return strongInstance!
    }
    
    
    public override init() {
        super.init()
        willDismissObserver = NotificationCenter.default.addObserver(forName: .RITLPhotosWillDismissNotificationName, object: nil, queue: nil) {[weak self] (_) in
            self?.dismissCallBack()
        }
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
        guard let willDismissObserver = willDismissObserver else { return }
        NotificationCenter.default.removeObserver(willDismissObserver)
    }
    
    ///开始生成图片并响应回调
    func startMake(complete: (()->())?) {
        //如果代理为空，则不进行操作即可
        guard delegate != nil else { return }
        //按照代理进行返回
        getAssetIndentifiers()
        getOriginalAssets()
        getThumbnailImages()
        getImageDatas()
        //执行
        complete?()
        //执行回调
        dismissCallBack()
    }
    
    
    private func dismissCallBack() {
        delegate?.photosViewControllerWillDismiss(viewController: bindViewController ?? UIViewController())
    }
    
    /// 获得所有资源的id
    private func getAssetIndentifiers() {
        delegate?.photosViewController(viewController: bindViewController ?? UIViewController(), assetIdentifiers: RITLPhotosDataManager.shareInstance().assetIdentifers)
    }
    
    /// 获得所有的原始资源
    private func getOriginalAssets() {
        delegate?.photosViewController(viewController: bindViewController ?? UIViewController(), assets: RITLPhotosDataManager.shareInstance().assets)
    }
    
    /// 获得所有的缩略图
    private func getThumbnailImages() {
        //如果缩略图为.zero
        guard thumbnailSize != .zero else { return }
        guard thumbnailSize.height > 0 && thumbnailSize.width > 0 else { return }
        //进行大小变换
        var thumbnailSize = self.thumbnailSize
        thumbnailSize.width *= UIScreen.main.scale
        thumbnailSize.height *= UIScreen.main.scale
        var images = [UIImage?]()
        var infos = [[AnyHashable : Any]?]()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        for asset in RITLPhotosDataManager.shareInstance().assets {
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: options) { (image, info) in
                //追加
                images.append(image)
                infos.append(info)
            }
        }
        //执行代理即可
        delegate?.photosViewController(viewController: bindViewController ?? UIViewController(), thumbnailImages: images.compactMap{ $0 }, infos: infos.compactMap{ $0 })
    }
    
    /// 获得原有的数据
    private func getImageDatas() {
        //是否为原图
        let isHighQuality = RITLPhotosDataManager.shareInstance().isHightQuality
        var datas = [Data?]()
        var infos = [[AnyHashable : Any]?]()
        let options = PHImageRequestOptions()
        options.deliveryMode = isHighQuality ? .highQualityFormat : .opportunistic
        options.isSynchronous = true
        
        for asset in RITLPhotosDataManager.shareInstance().assets {
            imageManager.requestImageData(for: asset, options: options) { (data, _, _, info) in
                datas.append(data)
                infos.append(info)
            }
        }
        //执行代理
        delegate?.photosViewController(viewController: bindViewController ?? UIViewController(), datas: datas.compactMap{ $0 }, infos: infos.compactMap{ $0 })
    }

}
