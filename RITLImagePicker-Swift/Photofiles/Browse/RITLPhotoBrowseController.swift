//
//  RITLPhotoBrowseController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2017/1/20.
//  Copyright © 2017年 YueWen. All rights reserved.
//

import UIKit

let ritl_browse_cellIdentifier = "ritl_browseCellIdentifier"
let ritl_browse_backImage = UIImage(named: "RITLPhotoBack")

class RITLPhotoBrowseController: UIViewController
{

    // MARK: public
    
    /// 当前控制器的viewModel
    var viewModel = RITLPhotoBrowseViewModel()
    
    
    /// 更新选中的图片数
    ///
    /// - Parameter count: 选中的图片数
    func update(numbersOfSelected count:Int)
    {
        let isHidden = count == 0
        
        ritl_numberLabel.isHidden = isHidden
        
        if !isHidden {
            
            ritl_numberLabel.text = "\(count)"
            
            // 社会放射动画
            ritl_numberLabel.transform = CGAffineTransform(scaleX: 0.1,y: 0.1)
            
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.ritl_numberLabel.transform = CGAffineTransform.identity
            })
        }
    }
    
    
    /// 更新高清显示的状态
    ///
    /// - Parameter isHight: 是否为高清状态
    func update(sizeForHightQuarity isHight:Bool)
    {
        let signColor = isHight ? UIColor.colorValue(with: 0x2dd58a) :  UIColor.darkGray
        let textColor = isHight ? UIColor.white : UIColor.darkGray
        
        // 设置UI
        ritl_signImageView.backgroundColor = signColor
        ritl_sizeSignLabel.textColor = textColor
        ritl_sizeLabel.textColor = textColor
        
        if !isHight {
            
            ritl_indicator.stopAnimating()
            ritl_sizeLabel.text = ""
        }
    }
    
    
    
    // MARK: private
    
    // MARK: View
    
    /// 展示图片的collectionView
    lazy fileprivate var ritl_collection : UICollectionView = {
       
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection : UICollectionView = UICollectionView(frame: CGRect(x: -5, y: 0, width: self.view.bounds.width + 10, height: self.view.bounds.height), collectionViewLayout: layout)
        
        collection.delegate = self
        collection.dataSource = self
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        
        if #available(iOS 10, *) {
            
            collection.prefetchDataSource = self
        }
        
        collection.register(RITLPhotoBrowseCell.self, forCellWithReuseIdentifier: ritl_browse_cellIdentifier)
        
        return collection
        
    }()
    
    
    /// 顶部的bar
    lazy fileprivate var ritl_topBar : UINavigationBar = {
        
        let topBar : UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 64))
        
        topBar.barStyle = .black
        topBar.setBackgroundImage(ritl_image(in: UIColor.black.withAlphaComponent(0.6)), for: UIBarMetrics.default)
        
        return topBar
    }()
    
    
    /// 返回
    lazy fileprivate var ritl_backItem : UIButton = {
        
        //位置
        let backItem = UIButton(frame: CGRect(x: 5, y: 0, width: 44, height: 44))
        backItem.center = CGPoint(x: backItem.center.x, y: self.ritl_topBar.bounds.height / 2)
        
        //属性
        backItem.setImage(ritl_browse_backImage, for: .normal)
        backItem.setTitleColor(.white, for: .normal)
        backItem.titleLabel?.font = .systemFont(ofSize: 30)
        backItem.titleLabel?.textAlignment = .center
        
        //响应
        backItem.action(at: .touchUpInside, handle: { [weak self](sender) in
            
            let _ = self?.navigationController?.popViewController(animated: true)
        })
        
        return backItem
    }()
    
    
    /// 选择
    lazy fileprivate var ritl_selectedItem : UIButton = {
        
        let button : UIButton = UIButton(frame: CGRect(x: self.ritl_topBar.bounds.width - 44 - 10, y: 0, width: 44, height: 44))
        button.center = CGPoint(x: button.center.x, y: self.ritl_topBar.bounds.height / 2)
        
        button.imageEdgeInsets = UIEdgeInsetsMake(12, 10, 8, 10)
        button.setImage(ritl_deselectedImage, for: .normal)
        
        button.action(at: .touchUpInside, handle: {[weak self] (sender) in
            
            self!.viewModel.select(in: self!.ritl_collection)
        })
        
        return button
    }()
    
    
    /// 底部的tabBar
    lazy fileprivate var ritl_bottomBar : UITabBar = {
       
        let bottomBar :UITabBar = UITabBar(frame: CGRect(x: 0, y: self.view.bounds.height - 44, width: self.view.bounds.width, height: 44))
        
        bottomBar.barStyle = .black
        bottomBar.backgroundImage = ritl_image(in: UIColor.black.withAlphaComponent(0.6))
        
        return bottomBar
    }()
    
    
    /// 发送按钮
    lazy fileprivate var ritl_sendButton : UIButton = {
       
        let button : UIButton = UIButton(frame: CGRect(x: self.ritl_bottomBar.bounds.width - 50 - 5, y: 0, width: 50, height: 40))
        button.center = CGPoint(x: button.center.x, y: self.ritl_bottomBar.bounds.height / 2)
        
        button.setTitle("发送", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.titleLabel?.textAlignment = .center
        
        button.action(at: .touchUpInside, handle: { [weak self](sender) in
            
            self?.viewModel.selected(in: (self?.ritl_collection)!)
        })
        
        return button
    }()
    
    
    /// 显示数目的标签
    lazy fileprivate var ritl_numberLabel : UILabel = {
        
        let label : UILabel = UILabel(frame: CGRect(x: self.ritl_sendButton.frame.origin.x - 20, y: 0, width: 20, height: 20))
        label.center = CGPoint(x: label.center.x, y: self.ritl_sendButton.center.y)
        
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "8"
        label.backgroundColor = .colorValue(with: 0x2dd58a)
        label.textColor = .white
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.clipsToBounds = true
        label.isHidden = true
        
        return label
    }()
    
    
    /// 高清图的响应Control
    lazy fileprivate var ritl_hightQuarityControl : UIControl = {
        
        let control : UIControl = UIControl(frame: CGRect(x: 0, y: 0, width: 150, height: self.ritl_bottomBar.bounds.height))
        
        //响应
        control.action(at: .touchUpInside, handle: { [weak self](sender) in
            
            self?.viewModel.hightQuality(statusChangedIn:(self?.ritl_collection)!)
            
        })
        
        return control
    }()
    
    
    /// 选中圆圈
    lazy fileprivate var ritl_signImageView : UIImageView = {
        
        let imageView : UIImageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 15, height: 15))
        imageView.center = CGPoint(x: imageView.center.x, y: self.ritl_hightQuarityControl.bounds.height / 2)
        
        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1.0
        
        return imageView
    }()
    
    
    /// 原图:
    lazy fileprivate var ritl_sizeSignLabel : UILabel = {
        
        var width = NSAttributedString(string: "原图", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 13)]).boundingRect(with: CGSize(width: 100, height: 30), options: .usesLineFragmentOrigin, context: nil).width + 10
        
        let label : UILabel = UILabel(frame: CGRect(x:self.ritl_signImageView.frame.maxX + 5 , y: 0, width: width, height: 25))
        
        label.center = CGPoint(x: label.center.x, y: self.ritl_hightQuarityControl.bounds.height / 2)
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.text = "原图:"
        
        return label
    }()
    
    
    /// 等待风火轮
    lazy fileprivate var ritl_indicator : UIActivityIndicatorView = {
       
        let indicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        indicator.frame = CGRect(x: self.ritl_sizeSignLabel.frame.maxX + 5, y: 0, width: 15, height: 15)
        indicator.center = CGPoint(x: indicator.center.x, y: self.ritl_hightQuarityControl.bounds.height / 2)
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    
    /// 照片大小
    lazy fileprivate var ritl_sizeLabel : UILabel = {
        
        let label = UILabel(frame: CGRect(x: self.ritl_sizeSignLabel.frame.maxX + 5, y: 0, width: self.ritl_hightQuarityControl.bounds.width - self.ritl_sizeSignLabel.bounds.width, height: 25))
        
        label.center = CGPoint(x: label.center.x, y: self.ritl_hightQuarityControl.bounds.height / 2)
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.text = ""
        
        return label
    }()
    
    
    // MARK: function
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        automaticallyAdjustsScrollViewInsets = false
        
        bindViewModel()
        
        view.addSubview(ritl_collection)
        view.addSubview(ritl_topBar)
        view.addSubview(ritl_bottomBar)
        
        ritl_topBar.addSubview(ritl_backItem)
        ritl_topBar.addSubview(ritl_selectedItem)
        
        ritl_bottomBar.addSubview(ritl_hightQuarityControl)
        ritl_bottomBar.addSubview(ritl_sendButton)
        ritl_bottomBar.addSubview(ritl_numberLabel)

        ritl_hightQuarityControl.addSubview(ritl_signImageView)
        ritl_hightQuarityControl.addSubview(ritl_sizeSignLabel)
        ritl_hightQuarityControl.addSubview(ritl_indicator)
        ritl_hightQuarityControl.addSubview(ritl_sizeLabel)
        
        
        //滚动到当前
        ritl_collection.scrollToItem(at: IndexPath(item: viewModel.current, section: 0), at: .centeredHorizontally, animated: false)
        
        //检测选择的数量
        viewModel.ritl_checkPhotoShouldSend()
        
        //检测高清状态
        viewModel.ritl_checkHightQuarityStatus()
    }

    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    deinit {
        
        print("\(self.self)deinit")
    }
    

    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //标记
        scrollViewDidEndDecelerating(ritl_collection)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
        viewModel.controllerWillDisAppear()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: custom function
    
    
    /// 绑定viewModel
    func bindViewModel()
    {
        //显示清晰图
        viewModel.ritl_browseCellRefreshHandle = { [weak self](image,asset,indexPath) in
            
            let strongSelf = self
            
            //获得当前cell
            let cell = strongSelf?.ritl_collection.cellForItem(at: indexPath)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: { 
                
                if cell != nil {
                 
                     (cell as! RITLPhotoBrowseCell).ritl_imageView.image = image
                }
                
            }, completion: nil)
        }
        
        
        //刷新选中按钮
        viewModel.ritl_browseSelectedBtnRefreshHandle = { [weak self](image) in
            
            let strongSelf = self
            
            strongSelf?.ritl_selectedItem.setImage(image, for: .normal)
        }
        
        
        //弹出警告
        viewModel.warningClosure = {[weak self](reuslt,count) in
            
            let strongSelf = self
            
            strongSelf?.present(alertControllerShow: count)
        }
        
        
        //模态消失
        viewModel.dismissClosure = { [weak self] in
            
            self?.dismiss(animated: true, completion: nil)
        }
        
        
        //显示选择的数量
        viewModel.ritl_browseStatusChangedHandle = { [weak self](enable,count) in
            
            let strongSelf = self
            
            strongSelf?.update(numbersOfSelected: count)
        }
        
        
        //设置bar的hidden
        viewModel.ritl_browseBarHiddenChangeHandle = {[weak self] (isHdden) in
            
            let strongSelf = self
            
            strongSelf?.ritl_topBar.isHidden = isHdden
            strongSelf?.ritl_bottomBar.isHidden = isHdden
        }
        
        
        //高清部分
        
        viewModel.ritl_browseQuarityChangeHandle = {[weak self] (isHight) in
            
            let strongSelf = self
            
            strongSelf?.update(sizeForHightQuarity: isHight)
        }
        
        
        viewModel.ritl_browseRequestQuarityHandle = {[weak self] (isHidden,selector) in
            
            let strongSelf = self
            
            let _ = strongSelf?.ritl_indicator.perform(NSSelectorFromString(selector as! String))
            
            strongSelf?.ritl_sizeLabel.isHidden = isHidden
        }
        
        
        viewModel.ritl_browseRequestQuarityCompletionHandle = {[weak self] (imageSize) in
            
            let strongSelf = self
            
            strongSelf?.ritl_sizeLabel.text = (imageSize as! String)
        }
    }
    
    
}


extension RITLPhotoBrowseController : UICollectionViewDataSource
{
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        viewModel.scrollViewModel(didEndDeceleratingIn: scrollView)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.numberOfItem(in: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : RITLPhotoBrowseCell = collectionView.dequeueReusableCell(withReuseIdentifier: ritl_browse_cellIdentifier, for: indexPath) as! RITLPhotoBrowseCell
        
        
        viewModel.image(at: indexPath, in: collectionView, isThum: true) {(image, asset) in
            
            cell.ritl_imageView.image = image
        }
        
        cell.ritl_photoBrowerSimpleTapHandle = { [weak self] (cell) in
            
            let strongSelf = self
            
            strongSelf?.viewModel.sendViewBarShouldChangedSignal()
        }
        
        return cell
    }

    
}


extension RITLPhotoBrowseController : UICollectionViewDelegateFlowLayout
{

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return viewModel.collectonViewModel(sizeForItemAt: indexPath, inCollection: collectionView)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return viewModel.collectonViewModel(minimumInteritemSpacingForSectionIn: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return viewModel.collectonViewModel(minimumLineSpacingForSectionIn: section)
    }
    
    
}


@available(iOS 10, *)
extension RITLPhotoBrowseController : UICollectionViewDataSourcePrefetching
{
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
        
    }
    
}
