//
//  NSString+ZPEncryption.h
//  ZPBasicUtility
//
//  Created by wenguang  pan on 8/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZPEncryption)

/**
 *  md5算法加密
 *
 *  @return 加密后字符串
 */
- (NSString *)zp_md5String;

/**
 *  sha1算法加密
 *
 *  @return 加密后字符串
 */
- (NSString *)zp_sha1String;

/**
 *  des算法加密
 *
 *  @param key 加密需要的key
 *
 *  @return 加密后字符串
 */
- (NSString *)zp_desStringWithKey:(NSString *)key;

/**
 *  3DES加密
 */
- (NSString*)zp_tripleDESWithKey:(NSString*)key;

@end
