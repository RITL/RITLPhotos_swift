# RITLPhotos-Swift

<div align="center"><img src="https://github.com/RITL/Swift-RITLImagePickerDemo/blob/master/RITLImagePicker-Swift/RITLPhotos.gif" height=500></img></div>

# 依赖的库
```
pod 'SnapKit'
```

# 使用方法
```Swift
let viewController = RITLPhotosViewController()
viewController.photo_delegate = self
viewController.defaultIdentifiers = defaultIds
let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout,
                               sizeForItemAt: IndexPath(item: 0, section: 0))
viewController.thumbnailSize = size
viewController.configuration.maxCount = 15
viewController.configuration.isSupportVideo = false

present(viewController, animated: true) {}
```

# 之前版本

- 请前往[Swift3.0版本](https://github.com/RITL/Swift-RITLImagePickerDemo/tree/swift3.0)分支获得之前版本的代码以及`README.md`
