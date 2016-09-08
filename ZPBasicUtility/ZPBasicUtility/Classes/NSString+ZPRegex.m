//
//  NSString+ZPRegex.m
//  ZPBasicUtility
//
//  Created by wenguang  pan on 8/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import "NSString+ZPRegex.h"

@implementation NSString (ZPRegex)

- (BOOL)isMatchChinese {
    ///匹配字符：以中文字
    NSString *chinese = @"^((?i)[\u4E00-\u9FA5])*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", chinese];
    return [predicate evaluateWithObject:self];
}

-(BOOL)isMatchPhoneNumberFormat
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    //    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regexmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regexcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regexcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regexct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    BOOL res1 = [regexmobile evaluateWithObject:self];
    BOOL res2 = [regexcm evaluateWithObject:self];
    BOOL res3 = [regexcu evaluateWithObject:self];
    BOOL res4 = [regexct evaluateWithObject:self];
    
    if (res1 || res2 || res3 || res4 ){
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isMatchPasswordFormat
{
    NSString *PASSWORD = @"^[a-zA-Z0-9]{6,20}+$";
    NSString *NUMBER = @".*[0-9].*";
    NSString *CHARACTER = @".*[a-zA-Z].*";
    
    NSPredicate *regexPassword = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PASSWORD];
    NSPredicate *regexNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", NUMBER];
    NSPredicate *regexCharacter = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CHARACTER];
    
    if ([regexPassword evaluateWithObject:self]
        && [regexNumber evaluateWithObject:self]
        && [regexCharacter evaluateWithObject:self]) {
        return YES;
    }else{
        return NO;
    }
}

@end
