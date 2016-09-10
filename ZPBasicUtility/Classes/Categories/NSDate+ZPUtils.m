//
//  NSDate+ZPFormat.m
//  ZPBasicUtility
//
//  Created by wenguang  pan on 9/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import "NSDate+ZPUtils.h"

@implementation NSDate (ZPUtils)

#pragma mark - 时间格式化

+ (NSString *)zp_formattedStringFromTimeInterval:(NSTimeInterval)timeInterval {
    return [self zp_formattedStringFromTimeInterval:timeInterval dateFormat:@"yyyy-MM-dd"];
}

+ (NSString *)zp_formattedStringFromTimeInterval:(NSTimeInterval)timeInterval dateFormat:(NSString *)dateFormat {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval ];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"HKT"];
    return [dateFormatter stringFromDate:date];
}


@end
