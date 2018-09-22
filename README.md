# Package
## Shell自动打包脚本

网上的自动打包脚本都只是单方面的打包，没有找到那种可以直接提交到FIr、蒲公英、App Store的，而且也都是用的是xcrun打包的，现在已经不能用了，xcode9.0以后就只能使用xcodebulid打包了。然后就去研究了一下自动打包模式。

我写的这个自动打包脚本，暂时只适用于使用cocoapods管理的项目进行自动打包，只要拿过去配置一下PackageConfigs.plist文件就可以进行打包了，无需改脚本文件，可以进行一次性打包多target，可以自动提交到FIr、蒲公英、App Store三个平台，想要提交到哪个平台在PackageConfigs.plist配置一下那个平台的信息就可以了。

我已经升级为了Xcode10和iOS12，亲测全部打包成功并上传到Fir、蒲公英、App Store，并且打出来的包App Store已经审核通过。

##首先，在这里下载脚本:  [https://github.com/GuiLQing/Package.git](https://github.com/GuiLQing/Package.git)。

![下载的脚本文件夹](https://upload-images.jianshu.io/upload_images/3103049-81571e159c8df791.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后直接将下载好的脚本文件夹放到项目的根目录下

![将脚本文件夹放到项目根目录](https://upload-images.jianshu.io/upload_images/3103049-01d58e2e5e652e9b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后将需要进行自动打包的项目的target配置好进行一次手动打包，这里举个例子吧，比如说我要打一个Release的上传到App Store的包，配置好证书，也可以选择自动配置证书，然后将scheme改成Release模式，然后进行手动打包，然后将包export导出，就会生成一个文件夹，里面会有一个ExportOptions.plist文件，把那个文件放进脚本文件夹下的ExportOptions文件夹里面，然后改一下名称，我这里是改成了XXX_Release，XXX_Release是我项目里面的target名。

![这是导出包里面的文件](https://upload-images.jianshu.io/upload_images/3103049-fbe6d4e550cedbda.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

拖进ExportOptions文件夹并改名，我的项目里面有三个target，分别是XXX_Local，XXX_Release，XXX_Test，所以我就对每个target分别进行手动打包，并导出相对应的ExportOptions.plist文件，并且分别命名。

![拖进ExportOptions文件夹并改名](https://upload-images.jianshu.io/upload_images/3103049-cba6aa34cbe8d0bb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##这里还有一个最重要的，需要点击Manage Schemes，将项目需要打包的scheme勾选后面那个shared，详情看下图：
![点击Manage Schemes](https://upload-images.jianshu.io/upload_images/3103049-8b52a6b85207049a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![勾选shared](https://upload-images.jianshu.io/upload_images/3103049-3e2f9c6c3e47ef51.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####前面的工作都做好了之后，以后就不需要再做前面的步骤了，剩下的就是PackageConfig.plist的修改了
可以看到，脚本打包文件夹内还有一个PackageConfig.plist的文件，这个文件就是用来配置打包信息和上传到平台所需要的信息的维护了。

![PackageConfig.plist文件配置](https://upload-images.jianshu.io/upload_images/3103049-87aa8aea74359d63.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###如果只有一个target，需要上传到所有平台，可以这样配置

![单个target配置](https://upload-images.jianshu.io/upload_images/3103049-a8b00fc1765631f2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###如果不需要上传到任何平台，把那些平台信息都清空就好了，或者是把那些update字段的key-value都删除。

---

##注意：这个PackageConfig.plist文件里的XXX_export_info对应的value是ExportOptions文件夹里面的.plist打包配置文件名
#####PackageConfig.plist里面的key，只能改前面的Scheme名，后面的_export_info、_export_mode、_update_app_store_username、_update_app_store_password、_update_pgyer_u_key、_update_pgyer_api_key、_update_fir_token这种命名都是不能改的，如果改了就需要改脚本里面的对应的命名了，例如XXX_Release_export_info，只能改XXX_Release部分。

所有东西都改好了之后，点击PackageScript这个exec文件就会开始打包了，生成的包会在Package文件夹下创建以Target命名的文件夹，包名生成规格会以Target拼接详细时间生成。

![包文件](https://upload-images.jianshu.io/upload_images/3103049-9752a2ecdc13d5d3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#####PackageScript的exec文件是已经赋予了权限的，可以直接双击运行的，PackageScript(备份).sh是备份出来的脚本文件，如果有需要可以去修改，然后重新赋予权限。
如果需要修改，就复制一份出来，将PackageScript(备份).sh更名为PackageScript.sh，然后修改好了之后，打开终端，cd到当前目录下，输入mv PackageScript.sh PackageScript，移除了.sh后缀，然后再输入sudo chmod +x PackageScript，把移除后缀后的PackageScript文件转为exec可执行文件。

#####如果需要研究.sh语法的，可以打开PackageScript(备份).sh这个脚本文件看，都已经写好了注释了。

简书地址：[https://www.jianshu.com/p/64e393e34537](https://www.jianshu.com/p/64e393e34537)
