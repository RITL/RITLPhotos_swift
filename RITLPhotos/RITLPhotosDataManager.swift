//
//  RITLPhotosDataManager.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/23.
//  Copyright © 2021 YueWen. All rights reserved.
//

import Foundation
import Photos

/// 数据处理
 public final class RITLPhotosDataManager: NSObject {
    
    /// 局部单例
    private static weak var instance: RITLPhotosDataManager?
    
    /// 是否为高质量，可以使用KVO监控
    @objc dynamic var isHightQuality = false
    /// 选中资源的个数，可是使用KVO监控
    @objc dynamic private(set) var count = 0
    
    
    /// 选中资源的标记位
    private(set) var assetIdentifers = [String]() {
        didSet {
            count = assetIdentifers.count
        }
    }
    private(set) var assets = [PHAsset]()

    /// 添加以及移除的observer
    var addOrRemoveObserver: ((_ isAdd: Bool, _ assetId: String, _ index: Int?)->())?
    /// 交换的observer
    var exchangeObserver: ((_ originalId: String, _ toProposedId: String)->())?
    
    /// 默认选中的标志位，用来二次进入默认选中的标记
    var defaultIdentifiers = [String]() {
        didSet {
            guard !defaultIdentifiers.isEmpty else { return }
            assetIdentifers.removeAll()
            assetIdentifers = defaultIdentifiers
            assets.removeAll()
            assets = RITLFetchResultTransformer.toArray(result: PHAsset.fetchAssets(withLocalIdentifiers: defaultIdentifiers, options: nil))
        }
    }
    
    /// 局部单例
    static func shareInstance() -> RITLPhotosDataManager {
        var strongInstance = instance
        objc_sync_enter(self)
        if strongInstance == nil {
            strongInstance = RITLPhotosDataManager()
            instance = strongInstance
        }
        objc_sync_exit(self)
        return strongInstance!
    }
    
    //action
    func add(asset: PHAsset) {
        assets.append(asset)
        assetIdentifers.append(asset.localIdentifier)
        //进行回调
        addOrRemoveObserver?(true, asset.localIdentifier, count - 1)
    }
    
    func remove(asset: PHAsset) {
        //获得索引
        guard let index = assets.firstIndex(of: asset) else { return }
        remove(atIndex: index)
    }
    
    func remove(atIndex index: Int) {
        let asset = assets.remove(at: index)
        assetIdentifers.remove(at: index)
        addOrRemoveObserver?(false, asset.localIdentifier, index)
    }
    
    func removeAll() {
        assets.removeAll()
        assetIdentifers.removeAll()
    }
    
    func exchange(atIndex1 index1: Int, to index2: Int) {
        //资源
        let asset = assets.remove(at: index1)
        assets.insert(asset, at: index2)
        //id
        let id = assetIdentifers.remove(at: index1)
        assetIdentifers.insert(id, at: index2)
//        assets.ritl_p_exchange(atIndex1: index1, index2: index2)
//        assetIdentifers.ritl_p_exchange(atIndex1: index1, index2: index2)
//        print(assetIdentifers)
        let originId = assetIdentifers.count > index2 ? assetIdentifers[index2] : ""
        let toProposedId = assetIdentifers.count > index1 ? assetIdentifers[index1] : ""
        exchangeObserver?(originId, toProposedId)
    }
    
    
    /// 进行自动添加或者删除的操作
    /// 如果不存在该资源，追加，并返回当前所在的个数(索引+1)
    /// 如果存在该资源，删除，并返回-1
    @discardableResult
    func addOrRemove(asset: PHAsset) -> Int {
        guard assetIdentifers.contains(asset.localIdentifier) else {
            add(asset: asset)
            return count
        }
        remove(asset: asset)
        return -1
    }
    
    /// 是否已经选择了asset
    func contain(asset: PHAsset) -> Bool {
        return assetIdentifers.contains(asset.localIdentifier)
    }
    
    deinit {
        ritl_p_print("RITLPhotosDataManager is deinit")
    }
}


//extension Array {
//
//    /// 进行位置的交换
//    mutating func ritl_p_exchange(atIndex1 index1: Int, index2: Int) {
//        //数字校验
//        guard (0..<count).contains(index1), (0..<count).contains(index2) else { return }
//        guard index1 != index2 else { return }
//        //交换即可
//        (self[index1],self[index2]) = (self[index2],self[index1])
//    }
//}
