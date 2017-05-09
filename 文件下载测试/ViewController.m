//
//  ViewController.m
//  文件下载测试
//
//  Created by xpchina2003 on 2017/5/5.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "ViewController.h"
#import "DownLoader.h"

@interface ViewController ()
@property (nonatomic, strong) DownLoader *downloader;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation ViewController
- (NSTimer *)timer
{
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}
- (DownLoader *)downloader
{
    if (_downloader==nil) {
        _downloader = [[DownLoader alloc] init];
    }
    return _downloader;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"];
//    [self.downloader downloadWithUrl:url];
    [self.downloader downLoader:url downLoadInfo:^(long long totalSize) {
        
    } progress:^(float pregress) {
        
    } success:^(NSString *cachePath) {
        
    } faild:^{
        
    }];
    
    [self.downloader setStateChangeInfo:^(DownLoadState state){
    
    }];
}

@end
