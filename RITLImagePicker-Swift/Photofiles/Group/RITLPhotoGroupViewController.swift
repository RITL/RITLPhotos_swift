//
//  RITLPhotoGroupViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/10.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit
import Photos


let cellIdentifier = "RITLPhotoGroupCell"

/// 显示组的控制器
class RITLPhotoGroupViewController: UITableViewController {

    /// viewModel
    var viewModel:RITLPhotoGroupViewModel = RITLPhotoGroupViewModel()
    
    
    // MARK: private
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 初始化tableView相关属性
        tableView.tableFooterView = UIView()
        tableView.register(RITLPhotoGroupCell.self, forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: viewModel, action: #selector(viewModel.dismiss))
        
        bindViewModel()
        
        //开始获取照片
        viewModel.fetchDefaultGroups()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    fileprivate func bindViewModel()
    {
        viewModel.dismissClosure = { [weak self] in
            
            let strongSelf = self

            strongSelf!.dismiss(animated: true, completion: nil)

        }
        
        
        viewModel.fetchGroupsCompletion = { [weak self](groups:id) in
        
            let strongSelf = self
                
            strongSelf!.tableView.reloadData()
                
            // 跳入第一个
            strongSelf!.ritl_tableView(strongSelf!.tableView, didSelectRowAt: IndexPath(row: 0, section: 1), animated: false)
        }
        
        
        viewModel.selectedCompletion = {[weak self](collection,indexPath,animate) in
            
            let strongSelf = self
                
            //跳转viewController
            let viewController = RITLPhotosViewController()

            let viewModel = viewController.viewModel
                
            //设置标题
            viewModel.navigationTitle = (collection as! PHAssetCollection).localizedTitle!
            viewModel.assetCollection = (collection as! PHAssetCollection)
                
            strongSelf!.navigationController?.pushViewController(viewController, animated: animate)
            
        }
        
    }
    
    fileprivate func ritl_tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath, animated:Bool)
    {
        viewModel.groupViewModel(ritl_didSelectRowAt: indexPath, animated: animated)
    }
    
    
    deinit
    {
        print("\(self.self)deinit")
    }
}



extension RITLPhotoGroupViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return viewModel.numberOfSections()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.tableView(section)
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:RITLPhotoGroupCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RITLPhotoGroupCell
        
        viewModel.loadGroupMessage(At: indexPath) { (title, image, realTime, count) in
            
            cell.ritl_titleLabel?.text = (realTime as! String)
            cell.ritl_imageView?.image = (image as! UIImage)
            
        }

        return cell as UITableViewCell
        
    }
}


extension RITLPhotoGroupViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //消除痕迹
        tableView.deselectRow(at: indexPath, animated: false)
        
        ritl_tableView(tableView, didSelectRowAt: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(viewModel.tableViewModel(heightForCellRowAt: indexPath))
    }
}
