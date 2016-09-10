//
//  NSString+ZPURLCoding.m
//  ZPBasicUtility
//
//  Created by wenguang  pan on 8/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import "NSString+ZPURLCoding.h"

@implementation NSString (ZPURLCoding)

//url 编码
- (NSString *)zp_encodeUrl {
    CFStringRef strRef = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]\"",kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithString:(__bridge NSString *)strRef];
    CFRelease(strRef);
    return url;
}

//url 解码
- (NSString *)zp_decodeUrl {
    CFStringRef strRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, (CFStringRef)@"!*'();:@&=+$,/?%#[]\"", kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithString:(__bridge NSString *)strRef];
    CFRelease(strRef);
    return url;
}

+ (NSDictionary*)zp_dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

+ (NSString *)zp_parameterStringForDictionary:(NSDictionary *)parameterDictionary {
    NSMutableString *queryString = [[NSMutableString alloc] init];
    int i = 0;
    
    for (NSString *aKey in [parameterDictionary allKeys]) {
        if (i > 0) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", [aKey zp_encodeUrl], [[parameterDictionary objectForKey:aKey] zp_encodeUrl]];
        i++;
    }
    
    return queryString;
}

@end
