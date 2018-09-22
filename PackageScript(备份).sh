#!/bin/sh

#获取要打包的工程的root目录下的Package脚本目录的绝对路径
export_path=$(dirname $0)
#当前位置跳到脚本位置
cd ${export_path}
#获取脚本所在的目录
export_path=$(pwd)
echo ${export_path}
#获取脚本所在的目录名称
export_path_name="${export_path##*/}"
echo ${export_path_name}
#获取要打包的工程的root目录的绝对路径
cd ..
#获取工程的root路径
project_path=$(pwd)
echo ${project_path}
#build文件夹路径
build_path=${project_path}/build
echo ${build_path}
#获取项目名称
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')


#通过获取打包的配置文件，解析出需要打包的scheme
package_path=${export_path}/PackageConfigs.plist
schemes_string=$(/usr/libexec/PlistBuddy -c "Print schemes" ${package_path})
schemes_array=(${schemes_string// / })
#遍历需要打包的scheme
for ((i=0;i<${#schemes_array[@]};i++)) do
    #需要打包的scheme
    scheme_name=${schemes_array[i]}
    echo ${scheme_name}
    #获取需要打包的export.plist信息
    export_info=$(/usr/libexec/PlistBuddy -c "Print ${scheme_name}_export_info" ${package_path})
    echo ${export_info}
    #获取需要打包的模式
    export_mode=$(/usr/libexec/PlistBuddy -c "Print ${scheme_name}_export_mode" ${package_path})
    echo ${export_mode}

    cd ${export_path}
    if [ ! -d ./${scheme_name} ];
    then
    mkdir -p ${scheme_name};
    fi

    scheme_export_path=$export_path/$scheme_name
    cd ${project_path}

    echo '///-----------'
    echo '/// 正在清理工程'
    echo '///-----------'

    #删除bulid目录
    if  [ -d ${build_path} ];then
    rm -rf ${build_path}
    echo clean build_path success.
    fi
    #清理工程
    xcodebuild \
    clean -configuration ${export_mode} -quiet  || exit

    echo '///--------'
    echo '/// 清理完成'
    echo '///--------'
    echo ''

    echo '///-----------'
    echo '/// 正在编译工程:'${export_mode}
    echo '///-----------'

    xcodebuild \
    archive -workspace ${project_path}/${project_name}.xcworkspace \
    -scheme ${scheme_name} \
    -configuration ${export_mode} \
    -archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit

    echo '///--------'
    echo '/// 编译完成'
    echo '///--------'
    echo ''

    echo '///----------'
    echo '/// 开始ipa打包'
    echo '///----------'

    xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
    -configuration ${export_mode} \
    -exportPath ${scheme_export_path} \
    -exportOptionsPlist $export_path/ExportOptions/${export_info} \
    -quiet || exit

    if [ -e $scheme_export_path/$scheme_name.ipa ]; then
        echo '///----------'
        echo '/// ipa包已导出'
        echo '///----------'

        #获取当前时间
        build_ipa_time=$(date +%Y-%m-%d_%H-%M-%S)
        echo ${build_ipa_time}
        #命名ipa的包,格式为:scheme名称_打包时间
        ipa_name=${scheme_name}_${build_ipa_time}
        echo ${ipa_name}

        cd ${scheme_export_path}
        mv $scheme_name.ipa $ipa_name.ipa
    else
        echo '///-------------'
        echo '/// ipa包导出失败 '
        echo '///-------------'
    fi
        echo '///------------'
        echo '/// 打包ipa完成  '
        echo '///-----------='
        echo ''

#    #将当前的绝对路径移动到桌面
#    cd ~/Desktop
#    #拷贝文件build文件夹中的ipa包至桌面
#    cp -r $scheme_export_path/$ipa_name.ipa  $(pwd)

    #清空bulid目录
    cd ${project_path}
    if  [ -d ${build_path} ];then
    rm -rf ${build_path}
    fi

    echo '///-------------'
    echo '/// 开始发布ipa包 '
    echo '///-------------'

    #获取需要上传到Fir的token
    fir_token=$(/usr/libexec/PlistBuddy -c "Print ${scheme_name}_update_fir_token" ${package_path})
    if [ ! $fir_token ]; then
        echo "fir_token 为空"
    else
        echo "~~~~~~~~~~~~~~~~正在上传ipa到Fir~~~~~~~~~~~~~~~~~~~"
        echo $fir_token
        #上传到Fir
        fir login -T $fir_token
        fir publish $scheme_export_path/$ipa_name.ipa

        echo "上传到Fir已完成"
    fi

    #获取需要上传到蒲公英的u_key和api_key
    pgyer_u_key=$(/usr/libexec/PlistBuddy -c "Print ${scheme_name}_update_pgyer_u_key" ${package_path})
    pgyer_api_key=$(/usr/libexec/PlistBuddy -c "Print ${scheme_name}_update_pgyer_api_key" ${package_path})
    if [ ! $pgyer_u_key -o ! $pgyer_api_key ]; then
        echo "pgyer_u_key 或者 pgyer_api_key 为空"
    else
        echo "~~~~~~~~~~~~~~~~正在上传ipa到蒲公英~~~~~~~~~~~~~~~~~~~"
        #自动上传到蒲公英
        pgyer_result=$(curl -F "file=@$scheme_export_path/$ipa_name.ipa" -F "uKey=$pgyer_u_key" -F "_api_key=$pgyer_api_key" https://www.pgyer.com/apiv1/app/upload)
        echo $pgyer_result

        echo "上传到蒲公英已完成"
    fi

    #获取需要上传到AppStore的用户名和密码
    app_store_username=$(/usr/libexec/PlistBuddy -c "Print ${scheme_name}_update_app_store_username" ${package_path})
    app_store_password=$(/usr/libexec/PlistBuddy -c "Print ${scheme_name}_update_app_store_password" ${package_path})
    if [ ! $app_store_username -o ! $app_store_password ]; then
        echo "app_store_username 或者 app_store_password 为空"
    else
        echo $app_store_username
        echo $app_store_password

        echo "~~~~~~~~~~~~~~~~正在上传ipa到AppStore~~~~~~~~~~~~~~~~~~~"

        #验证并上传到AppStore
        altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
        "$altoolPath" --validate-app -f $scheme_export_path/$ipa_name.ipa -u $app_store_username -p $app_store_password -t ios --output-format xml
        "$altoolPath" --upload-app -f $scheme_export_path/$ipa_name.ipa -u $app_store_username -p $app_store_password -t ios --output-format xml

        echo "上传到AppStore已完成"
    fi
done

echo "已完成此次打包上传过程 \(^o^)/"

exit 0
