<!--
 * @Author: zhaokuo 1516294663@qq.com
 * @Date: 2025-08-22 11:08:03
 * @LastEditors: zhaokuo 1516294663@qq.com
 * @LastEditTime: 2025-08-22 11:47:06
 * @FilePath: \undefinedd:\GitHub\ZK-compressed\README.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# ZK-compressed

## 概述

因为之前写的一个项目在进行图片上传的时候没启用压缩，初期用户少，没什么感觉，后来用户量上来后，上传速度变慢、下载超时、磁盘爆满😭，紧急上线了图片上传压缩功能， 但之前的图片已存储到了服务器上，用户列表过往数据时依旧会卡，所以想对服务器上的图片进行压缩，试了几个linux上的工具 有  `ImageMagick`、 `jpegoptim`， 用这两个工具时 压缩率很低时都失真严重(ps: 可能参数我没调好)，所以让AI写了这一个简单的图片压缩工具。

## 使用方法

1. 下载代码
2. 打包代码

- 在代码文件夹下打开终端
- 运行命令： `mvn clean package`
- 打包成功后，在target目录下生成jar包 `ZK-compressed-1.0-SNAPSHOT-jar-with-dependencies.jar`
- 然后可以运行jar包 `java -jar .\target\ZK-compressed-1.0-SNAPSHOT-jar-with-dependencies.jar "C:\Users\zhaokuo\Desktop\1.jpg" "C:\Users\zhaokuo\Desktop\1.jpg" 0.5` 传入3个参数 图片路径 压缩后的图片路径 压缩比例(0~1)

## linux运行

1. 在/script目录下提供了一个批处理脚本 `batch_compress_advanced.sh` 将其上传到服务器
2. 为脚本添加执行权限 `chmod +x batch_compress_advanced.sh`
3. 上传打包好的jar包 `ZK-compressed-1.0-SNAPSHOT-jar-with-dependencies.jar` 到服务器
4. 编辑脚本 `vim batch_compress_advanced.sh`
5. 修改脚本中jar包的路径 `APP_DIR` 和 jar包名 `JAR_NAME`
6. 可以使用 `./batch_compress_advanced.sh -h` 查看帮助
7. 脚本可选参数

   - `-h` 显示帮助信息
   - `-d` 试运行
   - `-s` 跳过已输出的文件 同文件夹覆盖时无效

8. 运行脚本 `./batch_compress_advanced.sh /usr/local/mes/files/images/2025/07/31 /usr/local/mes/files/images/2025/07/31_C 0.2`
