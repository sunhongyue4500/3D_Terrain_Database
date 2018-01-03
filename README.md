elevation_maker.sh脚本用于制作三维地形数据库

### 使用方法：

* 确保目录下有SRTM目录，该目录存放待处理的tif压缩包，如srtm.zip，如果是多个tif,使用gdal_merge.py 进行合并
* TargetTif目录用于存放解压后的tif文件
* baseSqlite目录存放待处理的源Sqlite数据库文件
* 执行脚本更新源Sqlite数据库文件


### 参考

README.txt
制作三维地形瓦片数据库.md
