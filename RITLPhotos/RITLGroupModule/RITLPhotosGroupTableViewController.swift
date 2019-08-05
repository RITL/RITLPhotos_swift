//
//  RITLPhotosGroupTableViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/29.
//  Copyright © 2019 YueWen. All rights reserved.
//

import UIKit
import Photos

/// RITLPhotos - 展示分组的界面
final class RITLPhotosGroupTableViewController: UITableViewController {

    /// 图片库
    private let photoLibrary = PHPhotoLibrary.shared()
    /// 存放所有相册组
    private var regularGroups = [PHAssetCollection]()
    /// 存放所有时刻的相册组
    private var momentGroups = [PHCollection]()
    /// 智能相册组
    private var regular: PHFetchResult<PHAssetCollection>?
    /// 片刻相册组
    private var moment: PHFetchResult<PHCollection>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem
        navigationItem.title = "照片"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(dismissPhotoControllers))
        
        
        //tableView
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 60
        tableView.register(RITLPhotosGroupCell.self, forCellReuseIdentifier: "groupCell")
        tableView.tableFooterView = UIView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard regularGroups.isEmpty && momentGroups.isEmpty else { return }
        //加载图片
        loadGroupCollections()
    }
    
    
    deinit {
        PHAssetCollection.removeAllCache()
        print("\(type(of: self)) I am dealloc")
    }

    
    /// 关闭按钮点击
    @objc func dismissPhotoControllers(){
        if let _ = navigationController?.presentingViewController {//模态弹出
            navigationController?.dismiss(animated: true, completion: nil)
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
}


extension RITLPhotosGroupTableViewController {
    
    /// 获取相册数据
    func loadGroupCollections(){
        
        PHPhotoLibrary.shared().fetchAblumRegularAndTopLevelUserResults(complete: { (regular, moment) in
            
            self.regular = regular
            self.moment = moment
            //进行遍历
            self.filterGroups()
            //刷新
            DispatchQueue.main.async { self.tableView.reloadData() }
            
        }) { (msg) in
            //失败
        }
    }
    
    
    /// 进行相册组的筛选
    func filterGroups(){
        
        guard let regular = self.regular, let moment = self.moment else { return }
        
        //进行智能相册的筛选
        let regularCollections = PHFetchResultHandler.transToArray(fetchResult: regular).sortedToUserLibraryFirst()
        //进行时刻的筛选
        let momentCollections = PHFetchResultHandler.transToArray(fetchResult: moment)
        
        //删除所有的数据
        regularGroups.removeAll()
        momentGroups.removeAll()
        
        //如果需要隐藏没有图片的相册，进行二次筛选
        
        //如果可以显示没有图片的相册
        regularGroups = regularCollections
        momentGroups = momentCollections
    }

}


extension RITLPhotosGroupTableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? regularGroups.count : momentGroups.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //进行获取
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        
        //进行解析
        guard let groupCell = cell as? RITLPhotosGroupCell, let collection = collection(at: indexPath) else { return cell }
        
        collection.image(size: CGSize(width: 30, height: 30), mode: .opportunistic) { (title, count, image) in
            if let title = title {
                groupCell.titleLabel.text = "\(title)  (\(count))"
            }
            groupCell.leadingImageView.image = image
        }

        return groupCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //跳转到详情视图
        guard let assetCollection = collection(at: indexPath) else { return }
       
        let viewController = RITLPhotosCollectionViewController(localIdentifier: assetCollection.localIdentifier)
        viewController.navigationItem.title = NSLocalizedString(assetCollection.localizedTitle ?? "相册", comment: "")
        navigationController?.pushViewController(viewController, animated: true)
    }
}


fileprivate extension RITLPhotosGroupTableViewController {
    
    /// 获得当前的资源集合
    func collection(at indexPath: IndexPath) -> PHAssetCollection? {
        if indexPath.section == 0 {//如果是智能相册
            return regularGroups[indexPath.row]
        }
        //如果不是，返回自定义的集合
        return momentGroups[indexPath.row] as? PHAssetCollection
    }
    
}
