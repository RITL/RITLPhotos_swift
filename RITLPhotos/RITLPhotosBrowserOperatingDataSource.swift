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
        
        imageView.ritl_photos_anchorEdge(to: contentView)
//
//        imageView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
    
    fileprivate func update(isSelected: Bool) {
        //
        imageView.layer.borderWidth = isSelected ? 4 : 0
        imageView.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.7333333333, blue: 0.3529411765, alpha: 1).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        assetIdentifer = ""
        imageView.image = nil
        imageView.layer.borderWidth = 0
    }
}


/// 操作的视图的数据源
public class RITLPhotosBrowserOperatingDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    /// 数据
    private let dataManager = RITLPhotosDataManager.shareInstance()
    ///
    private var collectionView: UICollectionView?
    /// 长按手势
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    /// 活动的cell
    private var cell: UICollectionViewCell?
    /// 资源化的manager
    private let imageManager = PHCachingImageManager()
    /// 选中的index
    private var selectIdentifier = ""
    
    //采用简单的closure
    var selectHandler: ((_ asset: PHAsset)->())?
    
    public override init() {
        super.init()
        dataManager.addOrRemoveObserver = { [weak self] (isAdd, id, index) in
            guard let index = index else { return }
            defer { //调整位置
                DispatchQueue.main.async { self?.adjustCollectionView() }
            }
            let indexPath = IndexPath(item: index, section: 0)
            //删除
            if !isAdd { self?.collectionView?.deleteItems(at: [indexPath]); return }
            //添加
            self?.collectionView?.insertItems(at: [indexPath])
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
        collectionView.backgroundColor = .clear
        collectionView.register(RITLPhotosBrowserOperatingCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.addGestureRecognizer(longPressGestureRecognizer)
        longPressGestureRecognizer.addTarget(self, action: #selector(longPressGestureRecognizerAction(gestureRecognizer:)))
    }
    
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
    
    
    @objc func longPressGestureRecognizerAction(gestureRecognizer: UILongPressGestureRecognizer) {
        //获得状态
        guard let collectionView = collectionView else { return }
        let p = gestureRecognizer.location(in: collectionView)//获得Point
        //开始手势
        switch gestureRecognizer.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: p) else { return }
            cell = collectionView.cellForItem(at: indexPath)
            collectionView.beginInteractiveMovementForItem(at: indexPath)
            //开始缩放动画
            if let actionCell = cell {
                UIView.animate(withDuration: 0.1) {
                    actionCell.transform = actionCell.transform.scaledBy(x: 1.2, y: 1.2)//开启放大动画
                }
            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(p)
        case .ended:
//            print("结束恢复")
            cell?.transform = .identity
            collectionView.endInteractiveMovement()
        default:
//            print("取消恢复")
            cell?.transform = .identity
            collectionView.cancelInteractiveMovement()
        }
    }
    
  
    //MARK: <UICollectionViewDataSource>
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell =  cell as? RITLPhotosBrowserOperatingCollectionViewCell {
            let asset = dataManager.assets[indexPath.item]
            cell.update(isSelected: asset.localIdentifier == selectIdentifier)
            //设置图片
            guard cell.assetIdentifer != asset.localIdentifier else { return }
            //获得数据
            var size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
            size = CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale)
            cell.assetIdentifer = asset.localIdentifier
//            print(indexPath)
//            print(asset.localIdentifier)
            //请求图片
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: PHImageRequestOptions()) { (image, _) in
                guard asset.localIdentifier == cell.assetIdentifer else { return }
                cell.imageView.image = image
//                print(indexPath)
            }
        }
    }
    
    //手势移动
    //MARK: <UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return proposedIndexPath
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        print(sourceIndexPath)
//        print(destinationIndexPath)
        let (sourceItem,destinationItem) = (sourceIndexPath.item,destinationIndexPath.item)
        guard sourceItem != destinationItem else { return } // 如果位置一样，不变化
        dataManager.exchange(atIndex1: sourceItem, to: destinationItem)//数据源交换
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 65, height: 65)
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
