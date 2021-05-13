## RITLPhotos-Swift
![](https://img.shields.io/badge/platform-iOS-orange.svg)
![](https://img.shields.io/badge/language-Swift-orange.svg)
![](https://img.shields.io/badge/support-iOS9+-blue.svg)
<div align="center"><img src="https://github.com/RITL/Swift-RITLImagePickerDemo/blob/master/RITLImagePicker-Swift/RITLPhotos.gif" height=500></img></div>


## 要求
- iOS 9.0+
- Swift 5.0+

## CocoaPods
```
use_frameworks!

pod 'RITLPhotos_swift', '~> 2.3.0'
```

## 使用方法
```Swift
let viewController = RITLPhotosViewController()
viewController.photo_delegate = self           //代理
viewController.defaultIdentifiers = defaultIds //默认选中的资源
viewController.thumbnailSize = CGSize(50,50)   //返回图片的缩略图大小
viewController.configuration.maxCount = 15     //最大支持的选择张数
viewController.configuration.isSupportVideo = false //是否支持视频，如果为false,则视频资源不能被选中

present(viewController, animated: true) {}
```

# 回调方法
``` Swift
/// 即将消失的回调
/// - Parameter viewController: RITLPhotosViewController
func photosViewControllerWillDismiss(viewController: UIViewController)

/// 获取权限失败的回调
/// - Parameters:
///   - viewController: RITLPhotosViewController
///   - denied: 获取权限失败的权限
func photosViewController(viewController: UIViewController, authorization denied: PHAuthorizationStatus)

/// 选中图片以及视频等资源的本地identifer
/// 可通过本次的回调，填出二次选择时设置默认选好的资源
/// - Parameters:
///   - viewController: RITLPhotosViewController
///   - identifiers: 选中资源的identifier
func photosViewController(viewController: UIViewController, assetIdentifiers identifiers: [String])


/// 选中图片以及视频等资源的默认缩略图
/// 根据thumbnailSize设置所得，
/// `如果thumbnailSize为.Zero,则不进行回调`
/// - Parameters:
///   - viewController: RITLPhotosViewController
///   - thumbnailImages: 选中资源的缩略图
///   - infos: 选中图片的缩略图信息
func photosViewController(viewController: UIViewController, thumbnailImages: [UIImage], infos: [[AnyHashable : Any]])


/// 选中图片以及视频等资源的数据
/// 根据是否选中原图所得
/// 如果为原图，则返回原图大小的数据
/// 如果不是原图，则返回原始比例的数据
/// 注: 不会返回thumbnailImages的数据大小
/// - Parameters:
///   - viewController: RITLPhotosViewController
///   - datas: 选中资源的Data类型
///   - infos: 选中图片的额外信息
func photosViewController(viewController: UIViewController, datas: [Data], infos: [[AnyHashable : Any]])


/// 选中图片以及视频等资源的源资源对象
/// 如果需要使用源资源对象进行相关操作,可以通过该方法拿到数据
/// - Parameters:
///   - viewController: RITLPhotosViewController
///   - assets: 选中的PHAsset对象
func photosViewController(viewController: UIViewController, assets: [PHAsset])


/// 选中的图片中包含已经由于外部相册删除或者其他原因导致加载失败的资源对象
/// 删除后不在其他的回调中进行回调
/// - Parameters:
///   - viewController: RITLPhotosViewController
///   - datas: 数据，包含被删除资源的原有资源对象，被删除资源的原有id，被删除资源的原有排序以及可能存在的信息
func photosViewController(viewController: UIViewController, fail datas: [(asset: PHAsset, id: String, index: Int, info: [AnyHashable: Any]?)])
```

## 之前版本

- 请前往[Swift3.0版本](https://github.com/RITL/Swift-RITLImagePickerDemo/tree/swift3.0)分支获得之前版本的代码以及`README.md`
