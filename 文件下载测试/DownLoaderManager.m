//
//  DownLoaderManager.m
//  文件下载测试
//
//  Created by 郭吉刚 on 17/5/8.
//  Copyright © 2017年 GJG. All rights reserved.
//

#import "DownLoaderManager.h"
#import "NSString+Download.h"

@interface DownLoaderManager () <NSCopying,NSMutableCopying>

@property (nonatomic, strong) NSMutableDictionary *downLoadInfo;

@end

@implementation DownLoaderManager
- (NSMutableDictionary *)downLoadInfo
{
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

static DownLoaderManager *_shareManager;
+ (instancetype)shareManager
{
    if (_shareManager == nil) {
        _shareManager = [[self alloc] init];
    }
    return _shareManager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (_shareManager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareManager = [[super alloc] init];
        });
    }
    return _shareManager;
}
- (id)copyWithZone:(NSZone *)zone
{
    return _shareManager;
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return _shareManager;
}



- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downloadInfo progress:(ProgressBlockType)progress success:(SuccessBlock)success faild:(FaildBlock)faild
{
    // url
    NSString *urlMD5 = [url.absoluteString md5];
    
    // 根据urlMd5，查找下载器
    DownLoader *downloader = self.downLoadInfo[urlMD5];
    if (downloader==nil) {
        downloader = [[DownLoader alloc] init];
        self.downLoadInfo[urlMD5] = downloader;
    }
    [downloader downLoader:url downLoadInfo:downloadInfo progress:progress success:success faild:faild];
    
    [downloader downLoader:url downLoadInfo:downloadInfo progress:progress success:^(NSString *cachePath) {
        
        [self.downLoadInfo removeObjectForKey:urlMD5];
       // 拦截block
        success(cachePath);
    } faild:faild];
    
}

- (void)pauseWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    DownLoader *downloader = self.downLoadInfo[urlMD5];
    [downloader pauseCurrentTask];
}
- (void)resumeWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    DownLoader *downloader = self.downLoadInfo[urlMD5];
    [downloader resumeCurrentTask];
}
- (void)cancelWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    DownLoader *downloader = self.downLoadInfo[urlMD5];
    [downloader cancelCurrentTask];
}

- (void)pauseAll
{
    [self.downLoadInfo.allValues performSelector:@selector(pauseCurrentTask) withObject:nil];
}
- (void)resumeAll
{
    [self.downLoadInfo.allValues performSelector:@selector(resumeCurrentTask) withObject:nil];
}


@end
