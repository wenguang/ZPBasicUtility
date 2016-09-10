//
//  ZPFileManager.m
//  ZPBasicUtility
//
//  Created by wenguang  pan on 9/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import "ZPFileManager.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "ZipArchive.h"

// OS_OBJECT_USE_OBJC 这个宏是在sdk6.0之后才有的,如果是之前的,则OS_OBJECT_USE_OBJC为0
// GDC是6.0引入的
// 之所以定义ZPDispatchQueueRelease这个宏，是因为在ARC环境下，出现release编译器会报错

#if OS_OBJECT_USE_OBJC
#undef ZPDispatchQueueRelease
#undef ZPDispatchQueueSetterSementics
#define ZPDispatchQueueRelease(q)
#define ZPDispatchQueueSetterSementics strong
#else
#undef ZPDispatchQueueRelease
#undef ZPDispatchQueueSetterSementics
#define ZPDispatchQueueRelease(q) (dispatch_release(q))
#define ZPDispatchQueueSetterSementics assign
#endif

#define FileHashDefaultChunkSizeForReadingData 1024*8

CFStringRef __FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        
        CFReadStreamClose(readStream);
        
        CFRelease(readStream);
        
    }
    
    if (fileURL) {
        
        CFRelease(fileURL);
        
    }
    
    return result;
}

@interface ZPFileManager ()

@property (ZPDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation ZPFileManager

- (id)init{
    self = [super init];
    if (self) {
        _ioQueue = dispatch_queue_create("com.wenguang.ZPFileManager", DISPATCH_QUEUE_SERIAL);
        dispatch_sync(_ioQueue, ^{
            _fileManager=[NSFileManager new];
        });
    }
    return self;
}

- (void)dealloc{
    ZPDispatchQueueRelease(_ioQueue);
}

+ (NSString *)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

+ (NSURL *)documentURL{
    return [NSURL URLWithString:[self documentPath]];
}

+ (NSString *)fileCachePath{
    return [[self documentPath] stringByAppendingPathComponent:@"FileCache"];
}

#pragma mark - 计算文件的MD5值

+(NSString*)fileMD5:(NSString*)filePath{
    if ([filePath length] > 0 && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return (__bridge_transfer NSString *)__FileMD5HashCreateWithPath((__bridge CFStringRef)filePath, FileHashDefaultChunkSizeForReadingData);
    }
    return nil;
}

#pragma mark - 读取文件转换为NSData，IO操作在独立的dispatch_queue_t中执行

- (NSData *)dataWithFilePath:(NSString *)filePath{
    NSData __block *fileData=nil;
    void(^fileAction)() = ^ {
        NSError *error=nil;
        fileData=[NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
        if (error) {
            NSLog(@"FileManager error:%@",[error localizedDescription]);
        }
    };
    
    dispatch_sync(_ioQueue, fileAction);
    
    return fileData;
}

- (NSData *)dataWithFileURL:(NSURL *)fileURL{
    NSString *filePath = [fileURL absoluteString];
    return [self dataWithFilePath:filePath];
}

- (void)dataWithFilePath:(NSString *)filePath completion:(ZPFileManagerCacheAction)action{
    dispatch_queue_t currentQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(_ioQueue, ^{
        NSError *error=nil;
        NSData *fileData=[NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
        if (error) {
            NSLog(@"<ZPFileManager>:%@",[error localizedDescription]);
            dispatch_async(currentQueue, ^{
                action(nil);
            });
        }else{
            dispatch_async(currentQueue, ^{
                action(fileData);
            });
        }
    });
}

- (void)dataWithFileURL:(NSURL *)fileURL completion:(ZPFileManagerCacheAction)action{
    NSString *filePath = [fileURL absoluteString];
    [self dataWithFilePath:filePath completion:action];
}

#pragma mark - 判断文件是否存在，IO操作在独立的dispatch_queue_t中执行

- (BOOL)fileExistsAtPath:(NSString *)filePath{
    BOOL __block isExist=NO;
    void(^fileAction)() = ^ {
        isExist=[self.fileManager fileExistsAtPath:filePath];
    };
    
    dispatch_sync(_ioQueue, fileAction);
    
    return isExist;
}

- (BOOL)fileExistsAtURL:(NSURL *)fileURL{
    NSString *filePath = [fileURL absoluteString];
    return [self fileExistsAtPath:filePath];
}

- (void)fileExistsAtPath:(NSString *)filePath completion:(ZPFileManagerCheckAction)action{
    dispatch_queue_t currentQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(_ioQueue, ^{
        BOOL isExist=[self.fileManager fileExistsAtPath:filePath];
        dispatch_async(currentQueue, ^{
            action(isExist);
        });
    });
}

- (void)fileExistsAtURL:(NSURL *)fileURL completion:(ZPFileManagerCheckAction)action{
    NSString *filePath = [fileURL absoluteString];
    [self fileExistsAtPath:filePath];
}

#pragma mark - 写文件，IO操作可选阻塞和非阻塞两种方式

- (void)writeData:(NSData *)fileData toFilePath:(NSString *)filePath waitUntilDone:(BOOL)willWait{
    if ([fileData length]<=0) {
        return;
    }
    void(^fileAction)() = ^ {
        NSError *error=nil;
        [fileData writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"<ZPFileManager>%@",[error localizedDescription]);
        }
    };
    if (willWait) {
        
        dispatch_sync(_ioQueue, fileAction);
        
    }else{
        dispatch_async(_ioQueue, fileAction);
    }
}

#pragma mark - 清除缓存文件

- (void)cleanCacheWithCompletion:(ZPFileManagerCleanAction)action{
    dispatch_queue_t currentQueue= dispatch_get_global_queue(0, 0);
    dispatch_async(_ioQueue, ^{
        NSString *filePath=[ZPFileManager fileCachePath];
        if([self.fileManager fileExistsAtPath:filePath isDirectory:nil]){
            [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"<ZPFileManager>:%@",[error localizedDescription]);
            }
            dispatch_async(currentQueue, ^{
                action();
            });
        }
    });
}

- (void)cleanCacheInBackgroundWithCompletion:(ZPFileManagerCleanAction)action{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    [self cleanCacheWithCompletion:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}


#pragma mark - 文件压缩、解压

- (void)unzipAndSaveFileNamed:(NSString*)filePath into:(NSString*)unZipDir {
    [self unzipAndSaveFileNamed:filePath into:unZipDir deleteZipFileAfterDone:YES];
}

- (void)unzipAndSaveFileNamed:(NSString*)filePath into:(NSString*)unZipDir deleteZipFileAfterDone:(BOOL)deleteZipFileAfterDone {
    
    void (^unZipAction)() = ^{
        
        ZipArchive* za = [[ZipArchive alloc] init];
#ifdef DEBUGX
        NSLog(@"%s %@", __FUNCTION__, fileName);
        NSLog(@"%s unzipping %@", __FUNCTION__, FilePath);
#endif
        if( [za UnzipOpenFile:filePath]){
            NSString *strPath=[NSString stringWithFormat:@"%@", unZipDir];
#ifdef DEBUGX
            NSLog(@"%s %@", __FUNCTION__, strPath);
#endif
            NSError *error;
            BOOL isDir;
            
            if ( !([self.fileManager fileExistsAtPath:[strPath stringByDeletingPathExtension] isDirectory:&isDir] && isDir))
                [self.fileManager createDirectoryAtPath:[strPath stringByDeletingPathExtension] withIntermediateDirectories:NO attributes:nil error:&error];
            
            //start unzip
            BOOL ret = [za UnzipFileTo:unZipDir overWrite:YES];
            if( NO==ret ){
                //解析错误，就删除文件
                NSError *error;
                if ([self.fileManager fileExistsAtPath:filePath]) {
                    [self.fileManager removeItemAtPath:filePath error:&error];
                }
                
            }
            [za UnzipCloseFile];
            
            if (deleteZipFileAfterDone) {
                //解压成功，删除zip包
                [self.fileManager removeItemAtPath:filePath error:nil];
            }
        }else{
            // error handler here
            //解析错误，就删除文件
            NSError *error;
            if ([self.fileManager fileExistsAtPath:filePath]) {
                [self.fileManager removeItemAtPath:filePath error:&error];
            }
            
        }
        
    };
    
    dispatch_sync(_ioQueue, unZipAction);
}


//让指定路径不让icloud同步，不然就违反了apple的核审规则

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
