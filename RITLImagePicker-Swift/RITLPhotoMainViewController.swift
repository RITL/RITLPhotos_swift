//
//  RITLMainViewController.swift
//  RITLImagePicker-Swift
//
//  Created by YueWen on 2016/11/29.
//  Copyright © 2016年 YueWen. All rights reserved.
//

import UIKit

class RITLPhotoMainViewController: UIViewController
{
    
    lazy var collectionView : UICollectionView = {
       
        let collectionView : UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.delegate = self
//        collectionView.dataSource = self
        
//        collectionView.backgroundColor = UIColor.colorValue(with: 0xF6FFB7)
        collectionView.backgroundColor = .white
        
//        collectionView.register(RITLPhotosCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        return collectionView
        
    }()
    
    
    var images = [UIImage]()

    
    
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
        
        self.images.removeAll()
        self.collectionView.reloadData()
    }
    
    /// 弹出图片控制器
    ///
    /// - Parameter sender: Photo Barbutton
    @IBAction private func presentPhotoViewController(_ sender: Any) {
        self.present(RITLPhotosViewController(), animated: true) {}
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





extension RITLPhotoMainViewController/* : UICollectionViewDataSource*/
{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        return images.count
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RITLPhotosCell
//
//        cell.ritl_imageView.image = self.images[indexPath.item]
//        cell.ritl_chooseImageView.isHidden = true
//
//        return cell
//    }
}
