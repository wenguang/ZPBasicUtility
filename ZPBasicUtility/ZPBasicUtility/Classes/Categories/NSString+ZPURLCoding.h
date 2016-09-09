//
//  NSString+ZPURLCoding.h
//  ZPBasicUtility
//
//  Created by wenguang  pan on 8/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZPURLCoding)

/**
 * url编码，对特殊字符和中文的处理
 */
-(NSString*)zp_encodeUrl;
-(NSString*)zp_decodeUrl;

/**
 * url query解析为dic
 */
+ (NSDictionary*)zp_dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding;
/** 
 * dic组合为url query字符串
 */
+ (NSString *)zp_parameterStringForDictionary:(NSDictionary *)parameterDictionary;

@end
