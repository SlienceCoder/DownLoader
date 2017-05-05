//
//  DownLoaderFileTool.m
//  文件下载测试
//
//  Created by xpchina2003 on 2017/5/5.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "DownLoaderFileTool.h"

@implementation DownLoaderFileTool
+ (BOOL)isFileExists:(NSString *)path
{
   return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
+ (long long)fileSizeWithPath:(NSString *)path
{
    if (![self isFileExists:path]) {
        return 0;
    }
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    long long size = [fileInfo[NSFileSize] longLongValue];
    
    return size;
}
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath
{
    if (![self isFileExists:fromPath]) {
        return ;
    }
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}
+ (void)removeFileAtPath:(NSString *)path
{
    if (![self isFileExists:path]) {
        return ;
    }
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}
@end
