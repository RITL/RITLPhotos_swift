//
//  RITLPhotosCollectionTableViewDataSource.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/16.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit
import Photos

/// 数据源
public class RITLPhotosRowTableViewDataSource: NSObject, UITableViewDataSource {

    /// 作为数据源的tableView
    weak var tableView: UITableView?
    /// 当前选中的collection的id
    var currentCollectionId = ""
    /// 数据源
    var datas = [[PHAssetCollection]]()
    
    
    /// 用来注册cell
    func registerTableViewAndCells(tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
        tableView.register(RITLPhotosRowTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? RITLPhotosRowTableViewCell {
            //获得item
            let item = datas[indexPath.section][indexPath.row]
            let collectionId = item.localIdentifier
            //进行设置
            item.ritl_p_image(size: CGSize(width: 52, height: 52), mode: .fastFormat, requestID: nil) { (collection, title, count, image, id) in
                //避免重复
                guard collection.localIdentifier == collectionId else { return }
                //开始赋值
                cell.titleLabel.text = title
                cell.countLabel.text = "\(count)"
                cell.iconImageView.image = image
                cell.selectedImageView.isHidden = !(self.currentCollectionId == collection.localIdentifier)
            }
        }
        return cell
    }
    
    deinit {
        print("\(type(of: self)) is deinit")
    }
}

extension RITLPhotosRowTableViewDataSource {
    
    /// 更新数据
    func update(currentId: String, datas: [[PHAssetCollection]]) {
        currentCollectionId = currentId
        self.datas = datas
        tableView?.reloadData()
    }
    
}
