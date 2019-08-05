//
//  RITLPhotosViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2019/7/29.
//  Copyright © 2019 YueWen. All rights reserved.
//

import UIKit

/// RITLPhotosPicker 的 启动控制器
final public class RITLPhotosViewController: UINavigationController {

    convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        //避免iOS13的presnet= .auto
        modalPresentationStyle = .fullScreen
        viewControllers = [RITLPhotosGroupTableViewController(),
                           RITLPhotosCollectionViewController()]
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
