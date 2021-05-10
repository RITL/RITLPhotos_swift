//
//  RITLPhotosBrowserOperatingView.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/5/8.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit

/// 操作的视图
public class RITLPhotosBrowserOperatingView: UIView {

    /// 集合
    private(set) lazy var collectionView: UICollectionView = {
        //flowLayout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        dataSource.bindCollectionView(collectionView: collectionView)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }()
    
    /// 数据源即可
    let dataSource = RITLPhotosBrowserOperatingDataSource()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ritl_p_print("\(type(of: self)) is deinit")
    }
}
