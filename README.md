# RITLPhotos-Swift

<div align="center"><img src="https://github.com/RITL/Swift-RITLImagePickerDemo/blob/master/RITLImagePicker-Swift/RITLPhotos.gif" height=500></img></div>

# 依赖的库
```
pod 'SnapKit'
```

# 使用方法
```Swift
let viewController = RITLPhotosViewController()
viewController.photo_delegate = self           //代理
viewController.defaultIdentifiers = defaultIds //默认选中的资源
viewController.thumbnailSize = CGSize(50,50)   //返回图片的缩略图大小
viewController.configuration.maxCount = 15     //最大支持的选择张数
viewController.configuration.isSupportVideo = false //是否支持视频，如果为false,则视频资源不能被选中

present(viewController, animated: true) {}
```

# 之前版本

- 请前往[Swift3.0版本](https://github.com/RITL/Swift-RITLImagePickerDemo/tree/swift3.0)分支获得之前版本的代码以及`README.md`
