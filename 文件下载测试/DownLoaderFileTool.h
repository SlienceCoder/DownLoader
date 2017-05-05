//
//  DownLoaderFileTool.h
//  文件下载测试
//
//  Created by xpchina2003 on 2017/5/5.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoaderFileTool : NSObject
+ (BOOL)isFileExists:(NSString *)path;
+ (long long)fileSizeWithPath:(NSString *)path;
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;
+ (void)removeFileAtPath:(NSString *)path;
@end
