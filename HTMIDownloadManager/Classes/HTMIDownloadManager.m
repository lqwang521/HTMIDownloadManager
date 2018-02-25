//
//  HTMIDownloadManager.m
//  大文件断点下载
//
//  Created by wlq on 18/02/25.
//  Copyright © 2018年 wlq. All rights reserved.
//

#import "HTMIDownloadManager.h"
#import "HTMIDownloadSessionManager.h"

#import "NSString+Hash.h"

@interface HTMIDownloadManager()

/**存放任务session以及其对应的URL的字典*/
@property(nonatomic,strong)NSMutableDictionary *sessionDictionary;

@end

@implementation HTMIDownloadManager

- (void)downloadFromURL:(NSString *)urlString progress:(void(^)(CGFloat downloadProgress))downloadProgressBlock complement:(void(^)(NSString *filePath,NSError *error))completeBlock
{
    if (![self.sessionDictionary.allKeys containsObject:urlString.md5String]) {
        HTMIDownloadSessionManager *downloadSessionManager = [[HTMIDownloadSessionManager alloc]init];
        self.sessionDictionary[urlString.md5String] = downloadSessionManager;
        [downloadSessionManager downloadFromURL:urlString progress:^(CGFloat downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !downloadProgressBlock?:downloadProgressBlock(downloadProgress);
            });
        }complement:^(NSString *filePath, NSError *error) {
            if (!error) {
                [self.sessionDictionary removeObjectForKey:urlString.md5String];
                dispatch_async(dispatch_get_main_queue(), ^{
                    !completeBlock?:completeBlock(filePath,nil);
                });
            }
        }];
        [downloadSessionManager resume];
    }
}

- (void)resumeTaskWithURL:(NSString *)urlString
{
    HTMIDownloadSessionManager *downloadSessionManager = self.sessionDictionary[urlString.md5String];
    if (!downloadSessionManager) {
        [NSException raise:@"There are no this task" format:@"Can not find the given url task"];
        return;
    }
    [downloadSessionManager resume];
}

- (void)resumeAllTasks
{
    [self.sessionDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, HTMIDownloadSessionManager  *_Nonnull obj, BOOL * _Nonnull stop) {
        [obj resume];
    }];
}

- (void)suspendTaskWithURL:(NSString *)urlString {
    HTMIDownloadSessionManager *downloadSessionManager = self.sessionDictionary[urlString.md5String];
    [downloadSessionManager suspend];
}

- (void)suspendAllTasks {
    [self.sessionDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, HTMIDownloadSessionManager  *_Nonnull obj, BOOL * _Nonnull stop) {
        [obj suspend];
    }];
}

- (void)cancelTaskWithURL:(NSString *)urlString {
    HTMIDownloadSessionManager *downloadSessionManager = self.sessionDictionary[urlString.md5String];
    [downloadSessionManager cancel];
}

- (void)cancelAllTasks {
   [self.sessionDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, HTMIDownloadSessionManager  *_Nonnull obj, BOOL * _Nonnull stop) {
       [obj cancel];
   }];
}

- (NSMutableDictionary *)sessionDictionary {
    if (!_sessionDictionary) {
        _sessionDictionary = [NSMutableDictionary dictionary];
    }
    return _sessionDictionary;
}

//单例的实现
static HTMIDownloadManager *_instance;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

@end
