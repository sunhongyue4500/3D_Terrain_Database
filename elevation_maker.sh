#!/bin/bash

. ticktick.sh

# 首先读取tif文件，求出经纬度范围（web mercator）
myLoc=${PWD}
echo "Script executed from: ${myLoc}"

# 迭代当前目录

srtmDirName="SRTM/"
srtmPath=${myLoc}/${srtmDirName}

# tif 文件路径
tifDirName="TargetTif/"
tifPath=${myLoc}/${tifDirName}

# elev_tile_pyramid程序路径
elev_pyexec="elev_tile_pyramid"
elev_pyPath=${myLoc}/${elev_pyexec}

# 待更新的源数据库
# source_sqliteDB="world_web_mercator.sqlite"
# world_web_mercator_pacnw
source_sqliteDB="world_web_mercator_pacnw.sqlite"
source_sqliteDBPath="${myLoc}/baseSqlite/${source_sqliteDB}"

targetDirName="targetDir"
targetDirPath=${myLoc}/${targetDirName}

# 层级设置 highLeve设置过大会导致生成的数据库文件过大
lowLeve=9
highLeve=13

echo ${tifPath}
echo ${elev_pyPath}
echo ${source_sqliteDBPath}

path="/var/www/html/test.php"

echo "$name"

for file in `ls ${srtmPath}`
do
  # unzip
  unzip "${srtmPath}${file}" -d ${tifPath}
  name=$(basename "${tifPath}$file" ".zip")
  echo "-------------------正在处理${name}-------------------"
  rm -r "${tifPath}${name}.hdr"
  rm -r "${tifPath}${name}.tfw"
  rm -r "${tifPath}readme.txt"
  # tif file path
  tempTifPath="${tifPath}${name}.tif"
  echo ${tempTifPath}
  # 获取返回值
  tempJson=`gdalinfo -json ${tempTifPath}`

  lowerLeftLon=($(gdalinfo -json ${tempTifPath} | jq '.cornerCoordinates.lowerLeft[0]'))
  lowerLeftLat=($(gdalinfo -json ${tempTifPath} | jq '.cornerCoordinates.lowerLeft[1]'))
  upperRightLon=($(gdalinfo -json ${tempTifPath} | jq '.cornerCoordinates.upperRight[0]'))
  upperRightLat=($(gdalinfo -json ${tempTifPath} | jq '.cornerCoordinates.upperRight[1]'))
  # scope
  # echo "lowerL:${lowerLeftLon} lowerR:${lowerLeftLat} upperL:${upperRightLon} uppperR:${upperRightLat}"
  # # proj4 计算mercatro 投影
  lower=$(echo ${lowerLeftLon} ${lowerLeftLat} | proj +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs)
  upper=$(echo ${upperRightLon} ${upperRightLat} | proj +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs)
  # echo "lower:${lower}"
  # echo "upper:${upper}"
  # 构造elev_pry
  ${elev_pyPath} -updatedb ${source_sqliteDBPath} -ue ${lowLeve} ${highLeve} ${lower} ${upper} ${tempTifPath}
  echo "-------------------${name}处理完毕-------------------"
done
