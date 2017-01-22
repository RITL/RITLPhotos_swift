//
//  RITLPhotoBrowseViewModel.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/20.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import Foundation
import Photos


class RITLPhotoBrowseViewModel: RITLBaseViewModel
{
    struct RITLPhotoBrowseViewModelAssociate
    {
        static let ritl_photoBrowViewAssociateBar = UnsafeRawPointer(bitPattern: "ritl_photoBrowViewAssociateBar".hashValue)
        static let ritl_photoBrowViewEndDeceleratingAssociate = UnsafeRawPointer(bitPattern: "ritl_photoBrowViewEndDeceleratingAssociate".hashValue)
    }
    
    
    
    // MARK: public
    
    /// 当前图片的位置指数
    var current : Int = 0
    
    /// 存储图片选择的所有资源对象
    var allAssets = [PHAsset]()
    
    /// 所有的图片资源
    var allPhotoAssets = [PHAsset]()
    
    /// 当前位置的cell应该显示清晰图的回调
    var ritl_browseCellRefreshHandle : ((UIImage,PHAsset,IndexPath) -> Void)?
    
    /// 当前的选中按钮刷新成当前图片状态
    var ritl_browseSelectedBtnRefreshHandle : ((UIImage) -> Void)?
    
    /// 浏览控制器将要消失的回调
    var ritl_browseWilldisappearHandle : ((Void) -> Void)?
    
    /// 响应是否显示当前数目标签以及数目
    var ritl_browseStatusChangedHandle : ((Bool,Int)->Void)?
    
    /// 控制器的bar对象隐藏的状态
    var ritl_browseBarHiddenChangeHandle : ((Bool) -> Void)?
    
    /*****   hight quarity   *****/
    
    /// 高清状态发生变化
    var ritl_browseQuarityChangeHandle : ((Bool) -> Void)?
    
    /// 请求高清数据过程
    var ritl_browseRequestQuarityHandle : ((Bool,id) -> Void)?
    
    /// 请求高清数据完毕
    var ritl_browseRequestQuarityCompletionHandle : ((id) -> Void)?
    
    
    
    /// 点击选择按钮,触发ritl_browseSelectedBtnRefreshHandle
    ///
    /// - Parameter scrollView: collectionView
    func select(in scrollView:UICollectionView)
    {
        let cacheManager = RITLPhotoCacheManager.sharedInstance
        
        //获得当前偏移量
        let currentIndex = ritl_index(indexFromAllPhotosToAll: Int(ritl_index(contentOffSetIn: scrollView)))
        
        //修改标志位
        let temp = cacheManager.assetIsSelectedSignal[currentIndex] ? -1 : 1
        
        cacheManager.numberOfSelectedPhoto += temp
        
        //判断是否达到上限
        guard cacheManager.numberOfSelectedPhoto <= cacheManager.maxNumeberOfSelectedPhoto else {
            
            //退回
            cacheManager.numberOfSelectedPhoto -= 1
            
            //弹出警告
            warningClosure?(false,UInt(cacheManager.maxNumeberOfSelectedPhoto))
            
            return
        }
        
        //修改状态
        cacheManager.ritl_change(selecteStatusIn: currentIndex)
        
        //检测
        ritl_checkPhotoShouldSend()
        
        //执行
        ritl_browseSelectedBtnRefreshHandle?(ritl_image(currentIndex))
    }
    
    
    /// 控制器将要消失的方法
    func controllerWillDisAppear()
    {
        ritl_browseWilldisappearHandle?()
    }
    
    
    /// 点击发送执行的方法
    ///
    /// - Parameter scrollView: collectionView
    func selected(in scrollView:UICollectionView)
    {
        let cacheManager = RITLPhotoCacheManager.sharedInstance
        
        //表示没有选择任何的照片
        let isEmpty = cacheManager.numberOfSelectedPhoto == 0
        
        //如果没有选择图片
        if isEmpty {
            
            //获得当前偏移量
            let currentIndex = ritl_index(indexFromAllPhotosToAll: Int(ritl_index(contentOffSetIn: scrollView)))

            //修改当前的标志位
            cacheManager.ritl_change(selecteStatusIn: currentIndex)
        }
        
        //获得所有选中的图片
        let  assets = RITLPhotoHandleManager.filter(assetsIn: allAssets, status: cacheManager.assetIsSelectedSignal)
        
        //进行bridge
        RITLPhotoBridgeManager.sharedInstance.start(renderFor: assets)
        
        //弹出
        dismissClosure?()
    }
    
    
    /// 获得当前的位置的图片对象
    ///
    /// - Parameters:
    ///   - indexPath: 所在位置
    ///   - collection: collectionView
    ///   - isThum: 是否为缩略图，如果为false，则按照图片原始比例获得
    ///   - completion: 完成
    func image(at indexPath:IndexPath,in collection:UICollectionView,isThum:Bool,completion:@escaping ((UIImage,PHAsset) -> Void))
    {
        //获得当前资源
        let asset = allPhotoAssets[indexPath.item]
        
        //图片比
        let scale = CGFloat(asset.pixelHeight) * 1.0 / CGFloat(asset.pixelWidth)
        
        //默认图片大小
        var size = CGSize(width: 60, height: 60 * scale)
        
        // 如果不是缩略图
        if !isThum {
            
            let height = (collection.bounds.width - 10) * scale
            
            size = CGSize(width: height / scale, height: height)
        }
        
        RITLPhotoHandleManager.asset(representionIn: asset, size: size) { (image, asset) in
            
            completion(image,asset)
        }
    }
    
    
    
    
    /// bar对象的隐藏
    func sendViewBarShouldChangedSignal()
    {
        guard (objc_getAssociatedObject(self, RITLPhotoBrowseViewModelAssociate.ritl_photoBrowViewAssociateBar)) != nil else {
         
            //需要隐藏
            objc_setAssociatedObject(self, RITLPhotoBrowseViewModelAssociate.ritl_photoBrowViewAssociateBar, true, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
            ritl_browseBarHiddenChangeHandle?(true); return
        }
        
        let isHidden = objc_getAssociatedObject(self, RITLPhotoBrowseViewModelAssociate.ritl_photoBrowViewAssociateBar) as! Bool
        
        //变换
        objc_setAssociatedObject(self, RITLPhotoBrowseViewModelAssociate.ritl_photoBrowViewAssociateBar, !isHidden, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        
        ritl_browseBarHiddenChangeHandle?(!isHidden)
    }
    
    
    
    /// 高清状态发生变化
    ///
    /// - Parameter scrollView:
    func hightQuality(statusChangedIn scrollView:UIScrollView)
    {
        let isHightQuality = RITLPhotoCacheManager.sharedInstance.isHightQuarity
        
        //变换标志位
        RITLPhotoCacheManager.sharedInstance.isHightQuarity = !isHightQuality
        
        ritl_checkHightQuarityStatus()
        
        //进入高清图进行计算
        if !isHightQuality {
            
            ritl_check(hightQuarityChangedAt: ritl_index(contentOffSetIn: scrollView))

        }
    }
    
    
    
    /// 检测当前是否可以发送图片
    func ritl_checkPhotoShouldSend()
    {
        let count = RITLPhotoCacheManager.sharedInstance.numberOfSelectedPhoto
        
        let enabel = count >= 1
        
        ritl_browseStatusChangedHandle?(enabel,count)
    }
    
    
    /// 检测浏览是否为高清状态
    func ritl_checkHightQuarityStatus()
    {
        ritl_browseQuarityChangeHandle?(RITLPhotoCacheManager.sharedInstance.isHightQuarity)
    }
    
    
    
    /// 点击发送执行的方法
    ///
    /// - Parameter collectionView: 当前的collectionview
    func photoDidSelectedComplete(_ collectionView:UICollectionView)
    {
        //获得筛选的数组
        let assets = RITLPhotoHandleManager.filter(assetsIn: self.allAssets, status: RITLPhotoCacheManager.sharedInstance.assetIsSelectedSignal)
        
        //进行回调
        RITLPhotoBridgeManager.sharedInstance.start(renderFor: assets)
        
        super.photoDidSelectedComplete()
    }
    
    deinit {
        
        print("\(self.self)deinit")
    }
    

    
    // MARK: pirvate
    
    
    ///
    /// 根据scrollView的偏移量获得当前资源的位置
    ///
    /// - Parameter scrollView: scrollView
    /// - Returns: 当前显示资源的位置
    fileprivate func ritl_index(contentOffSetIn scrollView:UIScrollView) -> Int
    {
        let collectionView = scrollView as! UICollectionView
        
        return Int(collectionView.contentOffset.x / collectionView.bounds.width)
    }
    
    
    
    
    /// 检测当前是否为高清状态，并执行响应的block
    ///
    /// - Parameter index: 当前展示图片的索引
    fileprivate func ritl_check(hightQuarityChangedAt index:Int)
    {
        let cacheManager = RITLPhotoCacheManager.sharedInstance
        
        guard cacheManager.isHightQuarity else {
            
            return
        }
        
        let currentAsset = allPhotoAssets[index]
        
        ritl_browseRequestQuarityHandle?(true,"startAnimating" as id)
        
        //获取高清数据
        RITLPhotoHandleManager.asset(hightQuarityFor: currentAsset, Size: CGSize(width: currentAsset.pixelWidth, height: currentAsset.pixelHeight)) { (size) in
            
            self.ritl_browseRequestQuarityHandle?(false,"stopAnimating" as id)
            self.ritl_browseRequestQuarityCompletionHandle?(size as id)
        }
    }
    
    
    
    /// 从所有的图片资源转换为所有资源的位置
    ///
    /// - Parameter index: 在所有图片资源的位置
    /// - Returns: 资源对象在所有资源中的位置
    fileprivate func ritl_index(indexFromAllPhotosToAll index:Int) -> Int
    {
        let currentAsset = allPhotoAssets[index]
        
        return allAssets.index(of: currentAsset)!
    }
    
    
    /// 所有的资源中是否被选择
    ///
    /// - Parameter index: 当前资源的位置
    /// - Returns: true表示被选，false表示没有被选
    fileprivate func ritl_isSelected(_ index:Int) -> Bool
    {
        return RITLPhotoCacheManager.sharedInstance.assetIsSelectedSignal[index]
    }
    
    
    
    ///  当前选择位置显示的图片
    ///
    /// - Parameter isSelected: 选中的状态
    /// - Returns:
    fileprivate func ritl_image(status isSelected:Bool = false) -> UIImage
    {
        return (isSelected ? ritl_selectedImage : ritl_deselectedImage)!
    }
    
    
    fileprivate func ritl_image(_ index:Int) -> UIImage
    {
        return ritl_image(status: ritl_isSelected(index))
    }
    
}


extension RITLPhotoBrowseViewModel : RITLCollectionViewModel
{
    func scrollViewModel(didEndDeceleratingIn scrollView:UIScrollView) {
        
        let currentIndex = ritl_index(contentOffSetIn: scrollView)
        
        //获得当前记录的位置
        let index = current
        
        // 判断是否为第一次进入
        let shouldIgnoreCurrentIndex = objc_getAssociatedObject(self, RITLPhotoBrowseViewModelAssociate.ritl_photoBrowViewEndDeceleratingAssociate)
        
        // 如果不是第一次进入并且索引没有变化，不操作
        if shouldIgnoreCurrentIndex != nil && index == currentIndex  {
            
            return
        }
    
        current = currentIndex
        
        //修改
        objc_setAssociatedObject(self, RITLPhotoBrowseViewModelAssociate.ritl_photoBrowViewEndDeceleratingAssociate, false, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        
        //获得indexPath
        let indexPath = IndexPath(item: currentIndex, section: 0)
        
        //请求高清图片
        image(at: indexPath, in: scrollView as! UICollectionView, isThum: false) { [weak self](image, asset) in
            
            self?.ritl_browseCellRefreshHandle?(image,asset,indexPath)
            
        }
        
        //执行判定
        ritl_browseSelectedBtnRefreshHandle?(ritl_image(ritl_index(indexFromAllPhotosToAll: currentIndex)))
        
        //变化
        ritl_check(hightQuarityChangedAt: currentIndex)
    }
    
    
    
    func numberOfItem(in section: Int) -> Int {
        
        return allPhotoAssets.count
    }
    
    
    
    func collectonViewModel(sizeForItemAt indexPath: IndexPath?, inCollection: UICollectionView) -> CGSize {
        
        return CGSize(width: inCollection.bounds.width, height: inCollection.bounds.height)
    }
    
    
    func collectonViewModel(minimumInteritemSpacingForSectionIn section: Int) -> CGFloat {
        
        return 0.0
    }
    
    
    func collectonViewModel(minimumLineSpacingForSectionIn section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectonViewModel(didEndDisplayCellForItemAt index: IndexPath) {
        
        ritl_browseSelectedBtnRefreshHandle?(ritl_image(index.item))
        
    }
}
 
