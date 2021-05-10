//
//  RITLPhotosBrowserOperatingDataSource.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/5/10.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

public class RITLPhotosBrowserOperatingCollectionViewCell: UICollectionViewCell {
    
    /// 用于标记图片的id
    var assetIdentifer = ""
    /// 展示的图片
    let imageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    fileprivate func update(isSelected: Bool) {
        //
        imageView.layer.borderWidth = isSelected ? 4 : 0
        imageView.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.7333333333, blue: 0.3529411765, alpha: 1).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/// 操作的视图的数据源
public class RITLPhotosBrowserOperatingDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// 数据
    private let dataManager = RITLPhotosDataManager.shareInstance()
    ///
    private var collectionView: UICollectionView?
    /// 资源化的manager
    private let imageManager = PHCachingImageManager()
    /// 选中的index
    private var selectIdentifier = ""
    
    //采用简单的closure
    var selectHandler: ((_ asset: PHAsset)->())?
    
    public override init() {
        super.init()
        dataManager.addOrRemoveObserver = { [weak self] (isAdd, id, index) in
            self?.collectionView?.reloadData()
        }
    }
    
    /// 选中当前的资源
    func select(asset: PHAsset, reload: Bool) {
        //如果与当前一致，返回即可
        //当前的id，未选中
        let localIdentifier = dataManager.contain(asset: asset) ? asset.localIdentifier : ""
        guard selectIdentifier != localIdentifier else { return }
        //之前的index
        let beforeIndex = dataManager.assetIdentifers.firstIndex { $0 == selectIdentifier }
        //记录
        selectIdentifier = asset.localIdentifier
        //之后的index
        let currentIndex = dataManager.assetIdentifers.firstIndex { $0 == selectIdentifier }
        defer {
            DispatchQueue.main.async {
                self.adjustCollectionView()////调整位置
            }
        }
        guard reload else { return }
        let items: [Int] = (beforeIndex == nil ? [] : [beforeIndex!]) + (currentIndex == nil ? [] : [currentIndex!])
        guard !items.isEmpty else { return }
        //进行cell的刷新
        collectionView?.reloadItems(at: items.map { IndexPath(item: $0, section: 0) })
    }
    
    /// 更正collectionView
    private func adjustCollectionView() {
        guard let currentIndex = (dataManager.assetIdentifers.firstIndex { $0 == selectIdentifier }) else { return }
        //当前的index滚动
        collectionView?.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    /// 绑定collectionView
    func bindCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.allowsMultipleSelection = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(RITLPhotosBrowserOperatingCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell =  cell as? RITLPhotosBrowserOperatingCollectionViewCell {
            
            //获得数据
            var size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0))
            size = CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale)
            let asset = dataManager.assets[indexPath.item]
            cell.assetIdentifer = asset.localIdentifier
            //请求图片
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: PHImageRequestOptions()) { (image, _) in
                guard asset.localIdentifier == cell.assetIdentifer else { return }
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell =  cell as? RITLPhotosBrowserOperatingCollectionViewCell {
            let asset = dataManager.assets[indexPath.item]
            cell.update(isSelected: asset.localIdentifier == selectIdentifier)
        }
    }
    

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = dataManager.assets[indexPath.item]
        //避免重复点击
        guard selectIdentifier != asset.localIdentifier else { return }
        selectHandler?(asset)
    }
}
