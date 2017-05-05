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
@end

@implementation ViewController
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
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/other5/jietu2.dmg"];
    [self.downloader downloadWithUrl:url];
}

@end
