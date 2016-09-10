//
//  NSString+ZPEncryption.m
//  ZPBasicUtility
//
//  Created by wenguang  pan on 8/9/16.
//  Copyright © 2016年 wenguang. All rights reserved.
//

#import "NSString+ZPEncryption.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>

@implementation NSString (ZPEncryption)

//MD5
- (NSString *)zp_md5String {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

- (NSString*)zp_sha1String
{
    const char *ptr = [self UTF8String];
    int i =0;
    CC_LONG len = (CC_LONG)strlen(ptr);
    Byte byteArray[len];
    
    while (i!=len) {
        unsigned eachChar = *(ptr + i);
        unsigned low8Bits = eachChar & 0xFF;
        byteArray[i] = low8Bits;
        i++;
    }
    
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(byteArray, (CC_LONG)len, digest);
    
    NSMutableString *hex = [NSMutableString string];
    for (int i=0; i<20; i++)
        [hex appendFormat:@"%02x", digest[i]];
    
    return [NSString stringWithString:hex];
}

//DES加密
- (NSString *)zp_desStringWithKey:(NSString *)key
{
    NSString *ciphertext = nil;
    const char *textBytes = [self UTF8String];
    NSUInteger dataLength = [self length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    Byte iv[] = {1,2,3,4,5,6,7,8};
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          textBytes, dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        //把des加密data转为16进制字符串
        Byte *bytes = (Byte *)[data bytes];
        //下面是Byte 转换为16进制。
        NSString *hexStr=@"";
        for(int i=0;i<[data length];i++)
            
        {
            NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
            
            if([newHexStr length]==1)
                
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            
            else
                
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
        return hexStr;
    }
    return ciphertext;
}

//3DES加密
- (NSString*)zp_tripleDESWithKey:(NSString*)key {
    
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *)[data bytes];
    
    //    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:NSUTF8StringEncoding];
    const void *vkey = (const void *)keyData.bytes;
    
    const void *vinitVec = nil;
    
    CCCrypt(kCCEncrypt,
            kCCAlgorithm3DES,
            kCCOptionECBMode|kCCOptionPKCS7Padding,
            vkey,
            kCCKeySize3DES,
            vinitVec,
            vplainText,
            plainTextBufferSize,
            (void *)bufferPtr,
            bufferPtrSize,
            &movedBytes);
    
    NSString *result;
    NSData *encryptData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    result = [encryptData base64EncodedStringWithOptions:NSUTF8StringEncoding];
    
    return result;
    
}

@end
