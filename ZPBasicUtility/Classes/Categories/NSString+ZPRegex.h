//
//  NSString+ZPRegex.h
//  ZPBasicUtility
//
//  Created by wenguang  pan on 8/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZPRegex)

/**
 * 匹配中文
 */
- (BOOL)zp_isMatchChinese;
/**
 * 匹配手机号
 */
- (BOOL)zp_isMatchPhoneNumberFormat;

@end
