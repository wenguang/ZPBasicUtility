//
//  NSString+ZPURLCoding.m
//  ZPBasicUtility
//
//  Created by wenguang  pan on 8/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import "NSString+ZPURLCoding.h"

@implementation NSString (ZPURLCoding)

//编码
- (NSString *)encodeUrl {
    CFStringRef strRef = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]\"",kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithString:(__bridge NSString *)strRef];
    CFRelease(strRef);
    return url;
}

//解码
- (NSString *)decodeUrl {
    CFStringRef strRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, (CFStringRef)@"!*'();:@&=+$,/?%#[]\"", kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithString:(__bridge NSString *)strRef];
    CFRelease(strRef);
    return url;
}

@end
