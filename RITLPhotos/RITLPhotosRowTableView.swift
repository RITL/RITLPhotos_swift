//
//  RITLPhotosCollectionTableView.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2021/4/16.
//  Copyright © 2021 YueWen. All rights reserved.
//

import UIKit

/// 代理方法
public protocol RITLPhotosRowTableViewDelegate: class {
    
    /// 将要展示的回调
//    func photosCollectionTableViewWillShow(view: RITLPhotosCollectionTableView)
    /// 将要消失的回调
    func photosCollectionTableViewShouldDismiss(view: RITLPhotosRowTableView)
}

/// 用于点击获得数据的列表
public class RITLPhotosRowTableView: UIView {

    /// 代理对象
    weak var delegate: RITLPhotosRowTableViewDelegate?
    /// 用于当做黑色遮罩容器
    private let containerView = UIView()
    
    /// 用于展示的列表tableView
    let tableView = UITableView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        backgroundColor = UIColor.systemYellow
        
        //设置背景点击响应
        let control = UIControl()
        control.addTarget(self, action: #selector(controlDidTap), for: .touchUpInside)
        addSubview(control)
        //设置tableView样式
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.rowHeight = 52
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0)

        //添加tableView
        addSubview(tableView)
        //由于使用动画，采用frame
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        tableView.backgroundView = {
            let view = UIView()
            view.backgroundColor = 47.ritl_p_color
            return view
        }()
        
        control.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func controlDidTap() {
        delegate?.photosCollectionTableViewShouldDismiss(view: self)
    }

    /// 更新tableView
    /// - Parameter isFold: 是否是折叠状态
    func updateTableViewFrame(isFold: Bool) {
        let height: CGFloat = isFold ? 0 : bounds.height / 7 * 5
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
    
    deinit {
        print("\(type(of: self)) is deinit")
    }

}


extension RITLPhotosRowTableView: UITableViewDelegate {
    

    
}
