#! /bin/bash

cd `dirname $0`
echo "当前工作目录 $(pwd)"

targetPath="../ipa_Jailbreak" #越狱文件目录
originPath="../ipa_source"	#appstore包文件
iTunesArtwork="iTunesArtwork.jpg"	#appstore 图片文件
iTunesMetadata="iTunesMetadata.plist" #appStore 应用信息
scriptPath=$(pwd) #当前脚本路径

if [[ -e "$originPath/$iTunesArtwork" ]]; then
	#statements
	echo "iTunesArtwork 文件存在"
else
	echo "iTunesArtwork 文件不存在"
	exit 
fi

if [[ -e "$originPath/$iTunesMetadata" ]]; then
	#statements
	echo "iTunesMetadata 文件存在"
else
	echo "iTunesMetadata 文件不存在"
	exit 
fi

if [[ -e $targetPath ]]; then
	#statements
	break
else
	echo "$targetPath 初始化"
	mkdir $targetPath
fi

if [[ -e $originPath ]]; then
	#statements
	break
else
	echo "$originPath 初始化"
	mkdir $originPath
fi

originIpa=""	#
appName="BJEducation_student.app" #app的name
pkName=".ipa"
editFile="AppInfo.plist"
editFilePath=""
contentFile="../content.txt"

rm -rf $targetPath/*

#查找文件夹下面的ipa包
funFindSoursePKFile(){
	cd "$1"
	for file in * ; do
		echo $file
		#statements	
		if [ -e $file ];
		then
			originIpa="$file"
			echo "源文件：$originIpa"
			break
		else
			echo "$originPath 没有ipa包"
			exit
		fi
	done
	cd $scriptPath
}

funFindSoursePKFile $originPath

echo "当前路径 $(pwd)"
#解压
cd ${originPath}
tar -xf ${originIpa}
open ${originPath}
cd $scriptPath
echo $(pwd)

#延时函数
funcDeley(){
	t=0
	echo "wait..."
	while [ $t -lt $1 ]; do
		#statements
		sleep 1s
		t=`expr $t + 1`
	done
	echo "contine..."
}

funcDeley 2

open $targetPath

#修改文件 $1:起始路径 $2:编辑的文件 $3:修改的内容
funFindSPlistFile(){
	cd $1
	echo "$1"
	for file in * ; do
		echo $file
		#statements	
		if [ -e $file ];
		then
			echo "源文件：$file"
			cd $file
			echo "当前工作目录 :$(pwd)"
				#statements
			find . -name $2 -ls
			ret=$?
			if [ $ret -eq 0 ]; then
				#statements
				editFilePath=$(pwd)/$2
				echo "找到需要需改的文件 :$editFilePath"
				defaults write $editFilePath channel $3
				# #修改文件
				echo "defaults write $editFilePath channel $3"
				echo "修改文件结果 $?"
			else
				echo "没有找到需要修改的文件"
				exit
			fi

		else
			echo "$1 没有文件"
		fi
	done
	cd $scriptPath
}

#修改并打包 $1:修改内容
EditPackage(){
	funFindSPlistFile "${originPath}/Payload" "${editFile}" $1
	cd $originPath
	echo $(pwd)
	#拷贝
	open Payload/
	cp $iTunesArtwork Payload/$iTunesArtwork
	cp $iTunesMetadata Payload/$iTunesMetadata

	#结果包名字
	targetfile=$originIpa
	targetfile=${originIpa/.ipa/_$1.ipa}
	echo "完成的文件:$targetfile"
	#打包
	# tar -cf ${targetfile} Payload/
	zip -r ${targetfile} Payload/
	echo "打包完成:$?"
	#完成包位置移动
	echo "cp ${targetfile}/${targetfile} ${targetPath}/${targetfile}"
	cp ${targetfile} ${targetPath}/${targetfile}
	echo "拷贝完成:$?"
	rm ${targetfile} #删除完成的包
	echo "删除临时文件完成:$?"
}

#读取配置文件方法 $1:配置文件路径
While_read_LINE() {
	while read LINE
	do 
		EditPackage $LINE
	done < $1
}

#读取配置并修改 
While_read_LINE $contentFile

rm -rf Payload
rm -rf Symbols

# #压缩
# tar -cf BJEducation_student_v2.2.0_1.ipa Payload/ Symbols/ 