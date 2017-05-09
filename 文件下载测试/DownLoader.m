//
//  DownLoader.m
//  文件下载测试
//
//  Created by xpchina2003 on 2017/5/5.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "DownLoader.h"
#import "DownLoaderFileTool.h"

#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTemp NSTemporaryDirectory()



@interface DownLoader ()<NSURLSessionDataDelegate>
{
    long long _tempFileSize;
    long long _totalFileSize;
}
@property (nonatomic, copy) NSString *cacheFilePath;
@property (nonatomic, copy) NSString *tempFilePath;


@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;

@end

@implementation DownLoader


- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downloadInfo progress:(ProgressBlockType)progress success:(SuccessBlock)success faild:(FaildBlock)faild
{
    // 赋值
    self.downLoadInfo = downloadInfo;
    self.progressChange = progress;
    self.success = success;
    self.faild = faild;
    
    // 开始下载
    [self downloadWithUrl:url];
}

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)downloadWithUrl:(NSURL *)url
{
    
    // 内部实现
    // 1.从头开始下载
    // 2.如果任务存在了，继续下载
    
    // 当前任务肯定存在
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        // 下载失败
        // 判断当前的状态，如果暂停状态
        
        if (self.states == DownLoadStatePause) {
            // 继续
            [self resumeCurrentTask];
            return;
        }
        
    }
    
    // 两种可能
    // 1.任务不存在 // 2.任务存在 url不同
    
    [self cancelCurrentTask];
    
    // 1.下载文件的存储
    NSString *fileName = [url lastPathComponent];
    self.cacheFilePath = [kCache stringByAppendingPathComponent:fileName];
    self.tempFilePath = [kTemp stringByAppendingPathComponent:fileName];
    
    
    // 首先判断本地有没有下载好，如果下载好就直接返回
    // 文件的位置，文件的大小
    if ([DownLoaderFileTool isFileExists:self.cacheFilePath]) {
        // 告诉外界下载已经完成
        NSLog(@"文件已经存在");
        
        self.states = DownLoadStateSuccess;
        return;
    }
    
    // 检测临时文件是否存在
    if (![DownLoaderFileTool fileSizeWithPath:self.tempFilePath]) {
        // 从0字节开始请求数据
        [self downloadWithURL:url offset:0];
        return;
    }
    
    // 走到这一步说明没有缓存
    // 2.读取本地缓存的大小
    _tempFileSize = [DownLoaderFileTool fileSizeWithPath:self.tempFilePath];
    [self downloadWithURL:url offset:_tempFileSize];
    
}

// 如果调用了几次继续
// 调用了几次暂停，才可以暂停
- (void)pauseCurrentTask
{
    if (self.states == DownLoadStateDownLoading) {
        self.states = DownLoadStatePause;
        [self.dataTask suspend];
    }
   
}
// 继续动作
// 如果调用了几次暂停，就需要调用几次继续，才可以继续
- (void)resumeCurrentTask
{
    if (self.dataTask && self.states == DownLoadStatePause ) {
        [self.dataTask resume];
        self.states = DownLoadStateDownLoading;
    }
    
}
- (void)cancelCurrentTask
{
    self.states = DownLoadStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)cancelAndClean
{
    [self cancelCurrentTask];
    // 删除缓存
    [DownLoaderFileTool removeFileAtPath:self.tempFilePath];
}



#pragma mark -NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    NSHTTPURLResponse *httpreponse = (NSHTTPURLResponse *)response;
    
    NSLog(@"%@",response);
    // 资源总大小
    // 1.从Content-Length获取
    // 2.如果Content-Range有，应该从Content-Range里面获取
    
    _totalFileSize = [httpreponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpreponse.allHeaderFields[@"Content-Range"]) {
        NSString *rangeStr = httpreponse.allHeaderFields[@"Content-Range"];
        _totalFileSize = [[[rangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    // 传递给外界
    if (self.downLoadInfo) {
        self.downLoadInfo(_totalFileSize);
    }
    
    
    
    if (_tempFileSize == _totalFileSize) {
        NSLog(@"下载完成");
        
        [DownLoaderFileTool moveFile:self.tempFilePath toPath:self.cacheFilePath];
        
        completionHandler(NSURLSessionResponseCancel);
        self.states = DownLoadStateSuccess;
        return;
    }
    
    if (_tempFileSize > _totalFileSize) {
        NSLog(@"删除，重新下载");
        
        [DownLoaderFileTool removeFileAtPath:self.tempFilePath];
        
        completionHandler(NSURLSessionResponseCancel);
        
        // 重新发送请求
        [self downloadWithURL:response.URL offset:0];
        
    }
    
    self.states = DownLoadStateDownLoading;
    // 正常接收数据
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempFilePath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"开始接受");
    
    // 当前下载带下
    _tempFileSize += data.length;
    
    self.progress = 1.0*_tempFileSize/_totalFileSize;
    
    [self.outputStream write:data.bytes maxLength:data.length];
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"完成");
    [self.outputStream close];
    self.outputStream = nil;
    
    if (error == nil) {
        // 不一定是成功
        
        NSLog(@"完成");
        self.states = DownLoadStateSuccess;
        [DownLoaderFileTool moveFile:self.tempFilePath toPath:self.cacheFilePath];
    } else {
        
        // 取消
        if (error.code == -999) { // 取消暂停
            self.states = DownLoadStatePause;
        } else { // 断网等情况
            self.states = DownLoadStateFaild;
        }
        
        
        NSLog(@"有错误");
    }
    
}
- (void)downloadWithURL:(NSURL *)url offset:(long long) offset
{
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    self.dataTask = [self.session dataTaskWithRequest:request];
    
    [self resumeCurrentTask];

    
}
#pragma mark -- 事件传递

- (void)setStates:(DownLoadState)states
{
    // 数据过滤,当数据改变的时候通知外界
    if (_states == states) {
        return;
    }
    _states = states;
    // 代理。block 通知
    if (self.stateChangeInfo) {
        self.stateChangeInfo(_states);
    }
    
    if (_states == DownLoadStateSuccess&&self.success) {
        self.success(self.cacheFilePath);
    }
    if (_states == DownLoadStateFaild&&self.faild) {
        self.faild();
    }
    
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if (self.progressChange) {
        self.progressChange(_progress);
    }
}
@end
