//
//  RITLPhotoGroupViewModel.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/10.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit
import Photos

typealias PhotoGroupCompletionClosure = PhotoCompleteBlock0
typealias PhotoGroupSelectedClosure = PhotoCompleteBlock4
typealias PhotoGroupMessageClosure = PhotoCompleteBlock2

/// 显示组的控制器的viewModel
class RITLPhotoGroupViewModel: RITLBaseViewModel
{
    
    // MARK: public
    
    /// 图片的带下
    var imageSize : CGSize = CGSize(width: 60, height: 60)
    
    /// 获取相册组完成的闭包
    var fetchGroupsCompletion : PhotoGroupCompletionClosure?
    
    /// 点击相册触发的闭包
    var selectedCompletion : PhotoGroupSelectedClosure?
    
    /// 控制器模态弹回，触发dismissGroupBlock
    func dismiss()
    {
        dismissClosure?()
    }
    
    
    /// 请求获取默认的相册组，完成触发fetchGroupsCompletion
    func fetchDefaultGroups()
    {
        photoStore.fetchDefaultAllGroups { [weak self](allGroups, collections) in
            
            if let strongSelf = self {
                
                strongSelf.groups = allGroups
                strongSelf.fetchGroupsCompletion?(allGroups as id)
            }
        }
    }
    
    
    /// 当前位置的PHAssetCollection对象
    ///
    /// - Parameter indexPathAt: 所在的位置
    /// - Returns: 当前位置的PHAssetCollection对象
    func assetCollection(indexPathAt indexPath:IndexPath) -> PHAssetCollection?
    {
        let row = indexPath.row
        
        if row > groups.count  {
            
            return nil
        }
        
        return groups[row]
    }
    
    
    /// 获取当前位置相册组和标题
    ///
    /// - Parameters:
    ///   - indexPath: 当前的位置
    ///   - completion: 获取信息完成的闭包,返回顺序:标题，图片，按照默认格式拼接的title,数量
    func loadGroupMessage(At indexPath:IndexPath,completion:@escaping PhotoGroupMessageClosure)
    {
        let collection = assetCollection(indexPathAt: indexPath)
        
        //获取资源
        RITLPhotoHandleManager.assetCollection(detailInformationFor:collection!, size: imageSize) { (title, count, image) in
         
            let realTitle = "\(NSLocalizedString(title!, comment: ""))(\(count))"
            
            completion(title as id,image as id,realTitle as id,count)
            
        }
    }
    
    
    /// 获取当前位置相册的所有照片集合
    ///
    /// - Parameter indexPath: 所在的位置
    /// - Returns: 当前当前位置相册的所有照片集合
    func fetchResult(photosIndexPathAt indexPath:IndexPath) -> PHFetchResult<AnyObject>
    {
        return PHAsset.fetchAssets(in: assetCollection(indexPathAt: indexPath)!, options: PHFetchOptions()) as! PHFetchResult<AnyObject>
    }
    
    
    /// 当前tableView的row被点击触发
    ///
    /// - Parameters:
    ///   - indexPath: 当前位置
    ///   - animated: 是否进行动画跳转
    func groupViewModel(ritl_didSelectRowAt indexPath:IndexPath, animated:Bool)
    {
        self.selectedCompletion?(assetCollection(indexPathAt: indexPath) as id,indexPath as id,animated)
    }
    
    
    // MARK: private
    fileprivate let photoStore = RITLPhotoStore()
    fileprivate var groups = [PHAssetCollection]()
    
//    deinit
//    {
//        print("\(self.self)deinit")
//    }
//    
}



extension RITLPhotoGroupViewModel : RITLTableViewModel
{
    
    var title: String {
        
        get{
            return "相册"
        }
    }
    
    
    func numberOfSections() -> Int{
        
        return 1
    }
    
    func tableView(_ numberOfRowInSection: Int) -> Int {
        
        return self.groups.count
    }
    

    func tableViewModel(heightForCellRowAt indexPath: IndexPath) -> Float {
        
        return 80
    }
}
