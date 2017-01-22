//
//  RITLPhotoNavigationViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/10.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit


/// 进入控制器的主导航控制器
class RITLPhotoNavigationViewController: UINavigationController {
    
    /// 控制器的viewModel
    var viewModel : RITLPhotoNavigationViewModel = RITLPhotoNavigationViewModel()


    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.viewControllers = [RITLPhotoGroupViewController()]
    }

    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit
    {
        print("\(self.self)deinit")
    }
}

