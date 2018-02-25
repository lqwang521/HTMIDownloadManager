//
//  HTMIViewController.m
//  大文件断点下载
//
//  Created by wlq on 18/02/25.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIViewController.h"
#import "HTMIDownloadManager.h"
#import <objc/runtime.h>
@interface HTMIViewController ()
/**downloadManager*/
@property(nonatomic,strong)HTMIDownloadManager *downloadManager;
@end

@implementation HTMIViewController
- (HTMIDownloadManager *)downloadManager
{
    if (!_downloadManager) {
        _downloadManager = [HTMIDownloadManager sharedManager];
    }
    return _downloadManager;
}

- (IBAction)start1:(id)sender {
    [[HTMIDownloadManager sharedManager] downloadFromURL:@"http://dldir1.qq.com/qqfile/qq/QQ8.3/18038/QQ8.3.exe" progress:^(CGFloat downloadProgress) {
        NSLog(@"task1-------- %.2f%%",downloadProgress * 100);
    } complement:^(NSString *filePath, NSError *error) {
        NSLog(@"task1-----%@,%@",filePath,error);
    }];
    
}

- (IBAction)start2:(id)sender {
        [self.downloadManager downloadFromURL:@"http://dldir1.qq.com/qqfile/qq/tm/2013Preview2/10913/TM2013Preview2.exe" progress:^(CGFloat downloadProgress) {
            NSLog(@"task2=========%@%.2f%%",[NSThread currentThread],downloadProgress * 100);
        } complement:^(NSString *filePath, NSError *error) {
            NSLog(@"task2=========%@,%@",filePath,error);
        }];
}
- (IBAction)suspend1:(id)sender {
    [self.downloadManager suspendTaskWithURL:@"http://dldir1.qq.com/qqfile/qq/QQ8.3/18038/QQ8.3.exe"];
}
- (IBAction)suspendAll:(id)sender {
    [self.downloadManager suspendAllTasks];
}
- (IBAction)resume1:(id)sender {
    [self.downloadManager resumeTaskWithURL:@"http://dldir1.qq.com/qqfile/qq/QQ8.3/18038/QQ8.3.exe"];
}
- (IBAction)resumeAll:(id)sender {
    [self.downloadManager resumeAllTasks];
}
- (IBAction)cancel1:(id)sender {
    [self.downloadManager cancelTaskWithURL:@"http://dldir1.qq.com/qqfile/qq/QQ8.3/18038/QQ8.3.exe"];
}
- (IBAction)cancelAll:(id)sender {
    [self.downloadManager cancelAllTasks];
}

@end
