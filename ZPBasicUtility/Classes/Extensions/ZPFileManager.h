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

+ (NSString *)documentPath;

+ (NSURL *)documentURL;

+ (NSString *)fileCachePath;

///计算文件的MD5值

+(NSString*)fileMD5:(NSString*)filePath;


///读取文件转换为NSData，IO操作在独立的dispatch_queue_t中执行

- (NSData *)dataWithFilePath:(NSString *)filePath;

- (NSData *)dataWithFileURL:(NSURL *)fileURL;

- (void)dataWithFilePath:(NSString *)filePath completion:(ZPFileManagerCacheAction)action;

- (void)dataWithFileURL:(NSURL *)fileURL completion:(ZPFileManagerCacheAction)action;


///判断文件是否存在，IO操作在独立的dispatch_queue_t中执行

- (BOOL)fileExistsAtPath:(NSString *)filePath;

- (BOOL)fileExistsAtURL:(NSURL *)fileURL;

- (void)fileExistsAtPath:(NSString *)filePath completion:(ZPFileManagerCheckAction)action;

- (void)fileExistsAtURL:(NSURL *)fileURL completion:(ZPFileManagerCheckAction)action;


///写文件，IO操作可选阻塞和非阻塞两种方式

- (void)writeData:(NSData *)fileData toFilePath:(NSString *)filePath waitUntilDone:(BOOL)willWait;


//清除缓存文件

- (void)cleanCacheWithCompletion:(ZPFileManagerCleanAction)action;

- (void)cleanCacheInBackgroundWithCompletion:(ZPFileManagerCleanAction)action;

@end
