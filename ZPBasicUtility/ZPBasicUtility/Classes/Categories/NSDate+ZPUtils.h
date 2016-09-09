//
//  NSDate+ZPFormat.h
//  ZPBasicUtility
//
//  Created by wenguang  pan on 9/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ZPUtils)

#pragma mark - 时间格式化

+ (NSString *)zp_formattedStringFromTimeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)zp_formattedStringFromTimeInterval:(NSTimeInterval)timeInterval dateFormat:(NSString *)dateFormat;

@end
