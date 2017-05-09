//
//  DownLoaderManager.h
//  文件下载测试
//
//  Created by 郭吉刚 on 17/5/8.
//  Copyright © 2017年 GJG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownLoader.h"

@interface DownLoaderManager : NSObject

+ (instancetype)shareManager;

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downloadInfo progress:(ProgressBlockType)progress success:(SuccessBlock)success faild:(FaildBlock)faild;
- (void)pauseWithURL:(NSURL *)url;
- (void)resumeWithURL:(NSURL *)url;
- (void)cancelWithURL:(NSURL *)url;

- (void)pauseAll;
- (void)resumeAll;
@end
