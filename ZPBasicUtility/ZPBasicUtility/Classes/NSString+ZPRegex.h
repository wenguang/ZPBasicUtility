//
//  NSString+ZPRegex.h
//  ZPBasicUtility
//
//  Created by wenguang  pan on 8/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZPRegex)

- (BOOL)isMatchChinese;
- (BOOL)isMatchPhoneNumberFormat;
- (BOOL)isMatchPasswordFormat;

@end
