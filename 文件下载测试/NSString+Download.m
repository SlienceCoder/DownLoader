//
//  NSString+Download.m
//  文件下载测试
//
//  Created by 郭吉刚 on 17/5/8.
//  Copyright © 2017年 GJG. All rights reserved.
//

#import "NSString+Download.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Download)
- (NSString *)md5
{
    const char *data = self.UTF8String;
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data, (CC_LONG)strlen(data), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}
@end
