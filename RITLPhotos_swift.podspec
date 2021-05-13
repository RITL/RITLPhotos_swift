#
# Be sure to run `pod lib lint RITLPhotos_swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RITLPhotos_swift'
  s.version          = '2.1.0'
  s.summary          = 'PhotosPicker'
  s.description      = "The Swift5.0 verson of the RITLPhotos,模仿微信,正在改进和优化"

  s.homepage         = 'https://github.com/RITL/Swift-RITLImagePickerDemo'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.authors           = { 'yuexiaowen' => 'yuexiaowen108@gmail.com' }
  
  s.swift_versions = ['5.0']

  s.ios.deployment_target = '9.0'
  
  s.source           = { :git => 'https://github.com/RITL/Swift-RITLImagePickerDemo.git', :tag => s.version }
  s.source_files  = "RITLPhotos/*.swift"

  s.requires_arc  = true
  s.frameworks    = "Foundation","UIKit","Photos","PhotosUI"
  s.resource     = 'RITLPhotos/Resource/RITLPhotos.bundle'
  
  s.dependency 'SnapKit', '~> 4.0.1'

end
