//
//  RITLScrollViewModel.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/10.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import Foundation
import UIKit

@objc protocol RITLScrollViewModel : RITLPublicViewModel
{
    /// scrollView滚动时的回调
    ///
    /// - Parameter contentOffSet: 当前滚动视图的偏移量
    @objc optional func scrollViewModel(didScroll contentOffSet:CGPoint)
    
    /// 滚动视图停止滑动进行上下修正
    ///
    /// - Parameter contentOffSet: 当前滚动视图的偏移量
    @objc optional func scrollViewModel(willEndDragging contentOffSet:CGPoint)

    /// 响应滚动视图减速完毕
    ///
    /// - Parameter contentOffSet: 当前滚动视图的偏移量
    @objc optional func scrollViewModel(didEndDecelerating contentOffSet:CGPoint)
    
    
    /// scrollView滚动时的回调
    ///
    /// - Parameter scrollView: 完毕的滚动视图
    @objc optional func scrollViewModel(didScrollIn scrollView:UIScrollView)

    /// 滚动视图停止滑动进行上下修正
    ///
    /// - Parameter scrollView: 完毕的滚动视图
    @objc optional func scrollViewModel(willEndDraggingIn scrollView:UIScrollView)
    
    /// 响应滚动视图减速完毕
    ///
    /// - Parameter scrollView: 完毕的滚动视图
    @objc optional func scrollViewModel(didEndDeceleratingIn scrollView:UIScrollView)

}


// MARK: TableView


@objc protocol RITLTableCellViewModel : RITLPublicViewModel
{
    
    /// 获得当前indexPath显示的标题
    ///
    /// - Parameter indexPath: 当前位置indexPath
    /// - Returns: 当前位置显示的标题
    @objc optional func tableViewCellModel(titleForCellRowAt indexPath:IndexPath) -> String?
    
    
    
    /// 获得当前indexPath显示标题的颜色
    ///
    /// - Parameter indexPath: 当前位置indexPath
    /// - Returns: 当前位置显示标题的颜色
    @objc optional func tableViewCellModel(colorForCellRowAt indexPath:IndexPath) -> UIColor?
    
    
    
    /// 获得当前indexPath位置cell背景色
    ///
    /// - Parameter indexPath: 当前位置indexPath
    /// - Returns: 当前位置的背景色
    @objc optional func tableViewCellModel(backColorForCellRowAt indexPath:IndexPath) -> UIColor?
    
    
    
    /// 获得当前indexPath显示的图像
    ///
    /// - Parameter indexPath: 当前位置indexPath
    /// - Returns: 当前位置显示的图片
    @objc optional func tableViewCellModel(imageForCellRowAt indexPath:IndexPath) -> UIImage?
    
}



@objc protocol RITLTableViewModel :  RITLScrollViewModel,RITLTableCellViewModel
{
    
    /// tableView的group数量
    ///
    /// - Returns: tableView的group数量
    @objc optional func numberOfSections() -> Int
    
    
    /// tableView每组的row数
    ///
    /// - Parameter numberOfRowInSection: section 当前的位置
    /// - Returns: 每组的row数量
    @objc optional func tableViewModel(_ numberOfRowInSection:Int) -> Int
    
    
    /// tableView每组的headerView的高度
    ///
    /// - Parameter inSection: 当前的section
    /// - Returns: 当前组的sectionheaderView的高度
    @objc optional func tableViewModel(heightSectionIn section:Int) -> Float
    
    
    ///  tableView的Cell高度
    ///
    /// - Parameter forRow: 当前位置的indexPath
    /// - Returns: 当前位置cell的高度
    @objc optional func tableViewModel(heightForCellRowAt indexPath:IndexPath) -> Float
    
    
    /// 当前位置的cell是否允许点击
    ///
    /// - Parameter indexPath: 当前位置的indexPath
    /// - Returns:
    @objc optional func tableViewModel(shouldHighlightRowAt indexPath:IndexPath) -> Bool
    
    
    /// 根据当前的位置执行控制器操作
    ///
    /// - Parameter indexPath: 当前位置的indexPath
    @objc optional func tableViewModel(didSelectRowAt indexPath:IndexPath)
    
    
    /// 当前section的footerView的高度
    ///
    /// - Parameter section:
    /// - Returns:
    @objc optional func tableViewModel(heightForFooterSectionIn section:Int) -> Float
    
}


// MARK: CollectionView

@objc protocol RITLCollectionCellViewModel : RITLPublicViewModel
{
    
    /// 获得当前indexPath显示的标题
    ///
    /// - Parameter indexPath: 当前位置indexPath
    /// - Returns: 当前位置显示的标题
    @objc optional func collectionCellModel(titleOfItemAt indexPath:IndexPath) -> String
    
    
    /// 获得当前indexPath显示的标题
    ///
    /// - Parameter index: 当前位置indexPath
    /// - Returns: 当前位置显示的标题
    @objc optional func collectionCellModel(attributeTitleOfItemAt index:IndexPath) -> NSAttributedString
    
    
    /// 获得当前indexPath显示的图像
    ///
    /// - Parameter index: 当前位置indexPath
    /// - Returns: 当前位置显示的图片
    @objc optional func collectionCellModel(imageOfItemAt index:IndexPath) -> UIImage
    
    
    /// 返回当前位置返回图片的url
    ///
    /// - Parameter index: 当前位置
    /// - Returns: 需要加载图片的url
    @objc optional func collectionCellModel(imageUrlStringForCellAt index:IndexPath) -> String
    
}



@objc protocol RITLCollectionViewModel : RITLScrollViewModel,RITLCollectionCellViewModel
{
    
    /// collection的组数
    ///
    /// - Returns: section的数目
    @objc optional func numberOfSection() -> Int
    

    /// CollectionView 每组item的个数
    ///
    /// - Parameter section: 组section
    /// - Returns: 当前section的个数
    @objc optional func numberOfItem(in section:Int) -> Int
    
    
    /// CollectionView 当前位置的大小
    ///
    /// - Parameters:
    ///   - indexPath: 位置indexPath
    ///   - inCollection: 执行方法的collection
    /// - Returns: 当前indexPath的item大小
    @objc optional func collectonViewModel(sizeForItemAt indexPath:IndexPath?, inCollection:UICollectionView) -> CGSize
    
    
    /// CollectionView 的footerView的大小
    ///
    /// - Parameters:
    ///   - section: 当前footerView的section
    ///   - inCollection: 执行方法的collectionView
    /// - Returns: 当前section的footerView的大小
    @objc optional func collectonViewModel(referenceSizeForFooterIn section:Int, inCollection:UICollectionView) -> CGSize
    
    
    /// CollectionView 每组section的最小间隔
    ///
    /// - Parameter index: 当前section
    /// - Returns: 当前section的间隔
    @objc optional func collectonViewModel(minimumLineSpacingForSectionIn section:Int) -> CGFloat
    
    
    /// CollectionView section中item的最小间隔
    ///
    /// - Parameter index: 当前section
    /// - Returns: 当前section中item的最小间隔
    @objc optional func collectonViewModel(minimumInteritemSpacingForSectionIn section:Int) -> CGFloat
    
    
    /// CollectionView 当前该位置的Cell能否点击
    ///
    /// - Parameter index: 当前位置
    /// - Returns: true表示可以点击，false反之
    @objc optional func collectonViewModel(shouldSelectItemAt index:IndexPath) -> Bool
    
    
    /// CollectionView 当前位置的Cell点击执行的操作
    ///
    /// - Parameter index: 当前位置
    @objc optional func collectonViewModel(didSelectedItemAt index:IndexPath)
    
    
    /// 当前位置的cell显示完毕执行的回调操作
    ///
    /// - Parameter index: 当前位置
    @objc optional func collectonViewModel(didEndDisplayCellForItemAt index:IndexPath)
    
    
    /// 预备处理
    ///
    /// - Parameter indexs:
    @available(iOS 10, *)
    @objc optional func collectonViewModel(prefetchItemsAt indexs:[IndexPath])
    
    
    /// 取消预备处理
    ///
    /// - Parameter indexs: 
    @available(iOS 10, *)
    @objc optional func collectonViewModel(cancelPrefetchingForItemsAt indexs:[IndexPath])
    
}


