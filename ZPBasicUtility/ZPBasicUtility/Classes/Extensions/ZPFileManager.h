//
//  ZPFileManager.h
//  ZPBasicUtility
//
//  Created by wenguang  pan on 9/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ZPFileManagerCacheAction)(NSData *fileData);
typedef void(^ZPFileManagerCheckAction)(BOOL isExist);
typedef void(^ZPFileManagerCleanAction)();

@interface ZPFileManager : NSObject

+ (NSString *)zp_documentPath;

+ (NSURL *)zp_documentURL;

+ (NSString *)zp_fileCachePath;

///计算文件的MD5值

+(NSString*)zp_fileMD5:(NSString*)filePath;


///读取文件转换为NSData，IO操作在独立的dispatch_queue_t中执行

- (NSData *)zp_dataWithFilePath:(NSString *)filePath;

- (NSData *)zp_dataWithFileURL:(NSURL *)fileURL;

- (void)zp_dataWithFilePath:(NSString *)filePath completion:(ZPFileManagerCacheAction)action;

- (void)zp_dataWithFileURL:(NSURL *)fileURL completion:(ZPFileManagerCacheAction)action;


///判断文件是否存在，IO操作在独立的dispatch_queue_t中执行

- (BOOL)zp_fileExistsAtPath:(NSString *)filePath;

- (BOOL)zp_fileExistsAtURL:(NSURL *)fileURL;

- (void)zp_fileExistsAtPath:(NSString *)filePath completion:(ZPFileManagerCheckAction)action;

- (void)zp_fileExistsAtURL:(NSURL *)fileURL completion:(ZPFileManagerCheckAction)action;


///写文件，IO操作可选阻塞和非阻塞两种方式

- (void)zp_writeData:(NSData *)fileData toFilePath:(NSString *)filePath waitUntilDone:(BOOL)willWait;


//清除缓存文件

- (void)zp_cleanCacheWithCompletion:(ZPFileManagerCleanAction)action;

- (void)zp_cleanCacheInBackgroundWithCompletion:(ZPFileManagerCleanAction)action;

@end
