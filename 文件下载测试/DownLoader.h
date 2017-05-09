//
//  DownLoader.h
//  文件下载测试
//
//  Created by xpchina2003 on 2017/5/5.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DownLoadState) {
    DownLoadStatePause,
    DownLoadStateDownLoading,
    DownLoadStateSuccess,
    DownLoadStateFaild
};

typedef void (^DownLoadInfoType)(long long totalSize);
typedef void (^ProgressBlockType)(float pregress);
typedef void (^SuccessBlock)(NSString *cachePath);
typedef void (^FaildBlock)();
typedef void (^StateChangeType)(DownLoadState state);
// 一个下载其对应一个下载任务
@interface DownLoader : NSObject


- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downloadInfo progress:(ProgressBlockType)progress success:(SuccessBlock)success faild:(FaildBlock)faild;


- (void)downloadWithUrl:(NSURL *)url;
- (void)pauseCurrentTask;
- (void)cancelCurrentTask;
- (void)resumeCurrentTask;
- (void)cancelAndClean;


// 数据
@property (nonatomic ,assign ,readonly) DownLoadState states;

// 事件&数据
@property (nonatomic, copy) DownLoadInfoType downLoadInfo;
@property (nonatomic, copy) StateChangeType stateChangeInfo;
@property (nonatomic, assign ,readonly) float progress;

@property (nonatomic, copy) ProgressBlockType progressChange;

@property (nonatomic, copy) SuccessBlock success;

@property (nonatomic, copy) FaildBlock faild;
@end
