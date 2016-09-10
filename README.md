# ZPBasicUtility
> 常用的一些扩展、工具类，特别对新搭建项目很有帮助，提高工作效率。

## 分类说明

* __NSString+ZPEncryption__: 字符串的加密算法，包括MD5、sha1、DES、3DES。

* __NSString+ZPRegex__: 字符串匹配、正则匹配

* __NSString+ZPURLCoding__: URL字符串编解码，对特殊字符和中文的处理；url参数转dic，dic转url参数。

* __UIVIew+ZPUtils__: 在View中通过事件响应者链获取当前的ViewController；用View加点击事件block，简化frame、size、origin、width、height等属性的获取和设置。

* __NSDate+ZPUitls__: NSTimeInterval转为格式化时间字符。

## 扩展说明

* __ZPFileManager__: 一个NSFileManager扩展，把相关IO操作放在一个独立的dispatch_queue_t中执行，提供获取App document目录、读取文件转换为NSData、判断文件是否存在、写文件（IO操作可选阻塞和非阻塞两种方式）、清除缓存文件、文件解压、设置指定目录不同步icloud。

	