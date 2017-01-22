//
//  RITLPhotosViewModel.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/17.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit
import Photos

typealias RITLPhotoDidTapHandle = PhotoCompleteBlock7
typealias RITLPhotoSendStatusHandle = PhotoCompleteBlock6


/// 选择图片的一级界面控制器的viewModel
class RITLPhotosViewModel: RITLBaseViewModel
{
    // MARK: public
    
    /// 当前显示的导航标题
    var navigationTitle : String = ""
    
    /// 当前显示的组对象
    var assetCollection : PHAssetCollection? {
        
        willSet{
            
            assetResult = RITLPhotoStore.fetchPhotos(newValue!)
            
            //初始化所有的图片数组
            RITLPhotoHandleManager.fetchResult(in: assetResult as! PHFetchResult<PHAsset>, type: PHAssetMediaType.image) { (allPhotos) in
                
                self.photosAssetResult = allPhotos
            }
            
        }
    }
    
    /// 存储该组所有的asset对象组合
    var assetResult : PHFetchResult<AnyObject>? {
        
        willSet{
            
            //初始化cacheManager
            RITLPhotoCacheManager.sharedInstance.ritl_memset(assetIsPictureSignal: (newValue?.count)!)
            RITLPhotoCacheManager.sharedInstance.ritl_memset(assetIsSelectedSignal: (newValue?.count)!)
            
            
            //初始化所有的资源对象
            RITLPhotoHandleManager.resultToArray(newValue!) { (assets, resultFetch) in
                
                self.assetsInResult = assets as! [PHAsset]
            }
        }
    }
    
    
    /// 图片被点击进入浏览控制器
    var photoDidTapShouldBrowerHandle : RITLPhotoDidTapHandle?
    
    /// 响应是否能够点击预览以及发送按钮
    var photoSendStatusChangedHandle : RITLPhotoSendStatusHandle?
    
    /// 点击预览进入浏览控制器的，暂时使用photoSendStatusChangedHandle替代
    var pushBrowerControllerByBrowerButtonHandle : RITLPhotoDidTapHandle?
    
    
    /// 资源数
    var assetCount : Int {
        
        get{
            return (self.assetResult?.count)!
        }
    }
    
    
    /// 通过点击浏览按钮弹出浏览控制器，触发pushBrowerControllerByBrowerButtonHandle
    func pushBrowerControllerByBrowerButtonTap()
    {
        let assets = RITLPhotoHandleManager.assets(assetsInResult, status: RITLPhotoCacheManager.sharedInstance.assetIsSelectedSignal)
        
        let index = 0
        
        photoDidTapShouldBrowerHandle?(assetResult!,assetsInResult as id,assets as id,"" as id, index)
    }
    
    
    
    override func photoDidSelectedComplete() {
        
        //获得筛选的数组
        let assets = RITLPhotoHandleManager.filter(assetsIn: self.assetsInResult, status: RITLPhotoCacheManager.sharedInstance.assetIsSelectedSignal)
        
        //进行回调
        RITLPhotoBridgeManager.sharedInstance.start(renderFor: assets)
        
        super.photoDidSelectedComplete()
    }
    
    
    
    
    /// 请求当前位置图片对象
    ///
    /// - Parameters:
    ///   - index: 所在位置
    ///   - inCollection: 所在的集合视图
    ///   - completion: 请求完成的图片，请求的资源对象，是否为图片，如果是视频存在时长
    func viewModel(imageAt index:IndexPath,inCollection:UICollectionView,completion:@escaping((UIImage,PHAsset,Bool,TimeInterval) -> Void))
    {
        
        let currentAsset = (assetResult?[index.item] as! PHAsset)
        let size = collectonViewModel(sizeForItemAt: nil, inCollection: inCollection)
        
        //获得详细信息
        RITLPhotoHandleManager.asset(representionIn: currentAsset, size: size) { (image, asset) in
            
            var isImage = false
            
            if asset.mediaType == .image {
                
                isImage = true
                self.cacheManager.assetIsPictureSignal[index.item] = true
            }
            
            completion(image,asset,isImage,asset.duration)
        }
    }
    
    
    /// 图片被选中的处理方法
    ///
    /// - Parameter index: 所在的位置
    /// - Returns: 是否选中
    func viewModel(didSelectedImageAt index:IndexPath) -> Bool
    {
        //修改标志位
        let isSelected = cacheManager.assetIsSelectedSignal[index.item]
        
        //记录
        cacheManager.numberOfSelectedPhoto += (isSelected ? -1 : 1)
        
        //如果已经超出最大限制
        guard cacheManager.numberOfSelectedPhoto <= cacheManager.maxNumeberOfSelectedPhoto else {
            
            cacheManager.numberOfSelectedPhoto -= 1
            
            //弹出提醒框
            warningClosure?(false,UInt(cacheManager.maxNumeberOfSelectedPhoto))
            
            return false
        }
        
        //修改
        cacheManager.assetIsSelectedSignal[index.item] = !isSelected
        
        //检测变化
        ritl_checkSendStatusChanged()
        
        return true
    }
    
    
    
    /// 该位置的图片是否选中
    ///
    /// - Parameter index: 所在位置
    /// - Returns: 当前图片的状态
    func viewModel(imageDidSelectedAt index:IndexPath) -> Bool
    {
        return cacheManager.assetIsSelectedSignal[index.item]
    }
    
    
    /// 检测当前可用状态
    func ritl_checkSendStatusChanged()
    {
        let count = cacheManager.numberOfSelectedPhoto
        let enable = count >= 1
        
        
        photoSendStatusChangedHandle?(enable,UInt(count))
    }
    

    
    deinit {
        
        cacheManager.freeAllSignal()
        print("\(self.self)deinit")
    }
    
    
    // MARK: private
    
    
    /// 存储该组所有的asset对象的数组
    fileprivate var assetsInResult = [PHAsset]()
    
    /// 存放当前所有的照片对象
    fileprivate var photosAssetResult = [PHAsset]()
    
    /// 缓存单例
    fileprivate var cacheManager = RITLPhotoCacheManager.sharedInstance
    

}


extension RITLPhotosViewModel : RITLCollectionViewModel
{
    
    var title: String{
        
        get{
            return self.navigationTitle
        }
    }
    
    
    
    func numberOfSection() -> Int {
        
        return 1
    }
    
    
    func numberOfItem(in section: Int) -> Int {
        
        return (assetResult?.count)!
    }
    
    
    func collectonViewModel(sizeForItemAt indexPath: IndexPath?, inCollection: UICollectionView) -> CGSize {
        
        let height = (inCollection.bounds.width - 3) / 4
        
        return CGSize(width: height, height: height)
    }
    
    
    func collectonViewModel(referenceSizeForFooterIn section: Int, inCollection: UICollectionView) -> CGSize {
        
        return CGSize(width:inCollection.bounds.width,height:44)
    }
    
    

    func collectonViewModel(minimumLineSpacingForSectionIn section: Int) -> CGFloat {
        
        return 1.0
    }
    

    
    func collectonViewModel(minimumInteritemSpacingForSectionIn section: Int) -> CGFloat {
        
        return 1.0
    }
    
    
    func collectonViewModel(shouldSelectItemAt index: IndexPath) -> Bool {
        
        return RITLPhotoCacheManager.sharedInstance.assetIsPictureSignal[index.item]
    }
    
    
    func collectonViewModel(didSelectedItemAt index: IndexPath) {
        
        // 获取当前的图片对象
        let asset = assetResult?[index.item] as! PHAsset
        
        //获得当前的位置
        let index : Int = photosAssetResult.index(of: asset)!
        
        photoDidTapShouldBrowerHandle?(assetResult!,assetsInResult as id,photosAssetResult as id,asset,index)
    }
    
    
    
    @available(iOS 10,*)
    func collectonViewModel(prefetchItemsAt indexs: [IndexPath]) {
        
    }
    
    @available(iOS 10,*)
    func collectonViewModel(cancelPrefetchingForItemsAt indexs: [IndexPath]) {
        
    }
    
}


