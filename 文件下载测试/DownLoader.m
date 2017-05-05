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

@end

@implementation DownLoader

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)downloadWithUrl:(NSURL *)url
{
    // 1.下载文件的存储
    self.cacheFilePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    self.tempFilePath = [kTemp stringByAppendingPathComponent:[url absoluteString]];
    
    
    // 首先判断本地有没有下载好，如果下载好就直接返回
    // 文件的位置，文件的大小
    if ([DownLoaderFileTool isFileExists:self.cacheFilePath]) {
        NSLog(@"文件已经存在");
        return;
    }
    
    // 走到这一步说明没有缓存
    // 2.读取本地缓存的大小
    _tempFileSize = [DownLoaderFileTool fileSizeWithPath:self.tempFilePath];
    [self downloadWithURL:url offset:_tempFileSize];
    
}
- (void)downloadWithURL:(NSURL *)url offset:(long long) offset
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    
    [task resume];

}

#pragma mark -NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    NSHTTPURLResponse *httpreponse = (NSHTTPURLResponse *)response;
    
    NSLog(@"%@",response);
    
    _totalFileSize = [httpreponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpreponse.allHeaderFields[@"Content-Range"]) {
        NSString *rangeStr = httpreponse.allHeaderFields[@"Content-Range"];
        _totalFileSize = [[[rangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    
    if (_tempFileSize == _totalFileSize) {
        NSLog(@"下载完成");
        [DownLoaderFileTool moveFile:self.tempFilePath toPath:self.cacheFilePath];
        
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    if (_tempFileSize > _totalFileSize) {
        NSLog(@"删除，重新下载");
        
        [DownLoaderFileTool removeFileAtPath:self.tempFilePath];
        
        completionHandler(NSURLSessionResponseCancel);
        
        // 重新发送请求
        [self downloadWithURL:response.URL offset:0];
    }
    
    // 正常接收数据
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempFilePath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"开始接受");
    [self.outputStream write:data.bytes maxLength:data.length];
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"完成");
    [self.outputStream close];
    self.outputStream = nil;
    
    if (error == nil) {
        NSLog(@"完成");
        [DownLoaderFileTool moveFile:self.tempFilePath toPath:self.cacheFilePath];
    } else {
        NSLog(@"有错误");
    }
}
@end
