# Package
Package

Shell自动打包脚本

网上的自动打包脚本都只是单方面的打包，没有找到那种可以直接提交到FIr、蒲公英、App Store的，而且也都是用的是xcrun打包的，现在已经不能用了，xcode9.0以后就只能使用xcodebulid打包了。然后就去研究了一下自动打包模式。
我写的这个自动打包脚本，只要拿过去配置一下PackageConfigs.plist文件就可以进行打包了，无需改脚本文件，可以进行一次性打包多target，可以自动提交到FIr、蒲公英、App Store三个平台，想要提交到哪个平台在PackageConfigs.plist配置一下那个平台的信息就可以了。
