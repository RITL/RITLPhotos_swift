//
//  RITLMainViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2016/11/29.
//  Copyright © 2016年 YueWen. All rights reserved.
//

import UIKit
import Photos

class RITLPhotoMainViewController: UIViewController {
    
    lazy var collectionView : UICollectionView = {
       
        let collectionView : UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.register(RITLPhotosNormalCollectionCell.self, forCellWithReuseIdentifier: "Cell")
        
        return collectionView
    }()
    
    lazy var photoViewController: RITLPhotosViewController = {
        let viewController = RITLPhotosViewController()
        viewController.photo_delegate = self

        let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout,
                                       sizeForItemAt: IndexPath(item: 0, section: 0))
        viewController.thumbnailSize = size
        viewController.configuration.maxCount = 15
        viewController.configuration.isSupportVideo = false
        
        return viewController
    }()
    
    
    var images = [UIImage]()
    var defaultIds = [String]()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.addSubview(collectionView)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func __refreshCollectionView(_ sender: Any) {
        
        defaultIds.removeAll()
        images.removeAll()
        collectionView.reloadData()
    }
    
    /// 弹出图片控制器
    ///
    /// - Parameter sender: Photo Barbutton
    @IBAction private func presentPhotoViewController(_ sender: Any) {

        photoViewController.defaultIdentifiers = defaultIds
        self.present(photoViewController, animated: true) {}
    }
}


extension RITLPhotoMainViewController: RITLPhotosViewControllerDelegate {
    
    func photosViewControllerWillDismiss(viewController: UIViewController) {
        ritl_p_print("\(#file)_\(#function)_\(#line)")
    }
    
    func photosViewController(viewController: UIViewController, assets: [PHAsset]) {
        ritl_p_print("\(#file)_\(#function)_\(#line)")
    }
    
    func photosViewController(viewController: UIViewController, assetIdentifiers identifiers: [String]) {
        ritl_p_print("\(#file)_\(#function)_\(#line)")
        defaultIds = identifiers
    }
    
    func photosViewController(viewController: UIViewController, datas: [Data], infos: [[AnyHashable : Any]]) {
        ritl_p_print("\(#file)_\(#function)_\(#line)")
    }
    
    func photosViewController(viewController: UIViewController, thumbnailImages: [UIImage], infos: [[AnyHashable : Any]]) {
        ritl_p_print("\(#file)_\(#function)_\(#line)")
        images = thumbnailImages
        collectionView.reloadData()
    }
    
    func photosViewController(viewController: UIViewController, authorization denied: PHAuthorizationStatus) {
        ritl_p_print("\(#file)_\(#function)_\(#line)")
//        viewController.alert("111")
//        viewController.dismiss(animated: true) {
//            print("Alert!")
//        }
    }
}





extension RITLPhotoMainViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.frame.size.width - 3) / 4
        
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
}





extension RITLPhotoMainViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RITLPhotosNormalCollectionCell
        
        cell.iconImageView.image = self.images[indexPath.item]
        cell.chooseButton.isHidden = true

        return cell
    }
}
