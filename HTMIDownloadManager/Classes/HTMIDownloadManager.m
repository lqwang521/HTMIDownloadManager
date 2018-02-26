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

#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

@interface HTMIDownloadManager()

/**存放任务session以及其对应的URL的字典*/
@property(nonatomic,strong)NSMutableDictionary *sessionDictionary;

@property (nonatomic, strong) NSMutableArray *paths;

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

#pragma mark - 老版本

+ (unsigned long long)fileSizeForPath:(NSString *)path {
    
    return [[self alloc] fileSizeForPath:path];
}

+ (id)downloadFileWithURLString:(NSString *)URLString
                      cachePath:(NSString *)cachePath
                       progress:(DownloadProgressBlock)progressBlock
                        success:(DownloadSuccessBlock)successBlock
                        failure:(DownloadFailureBlock)failureBlock {
    
    return [[self alloc] downloadFileWithURLString:URLString
                                         cachePath:cachePath
                                          progress:progressBlock
                                           success:successBlock
                                           failure:failureBlock];
}

+ (id)downloadFileWithURLString:(NSString *)URLString
                      cachePath:(NSString *)cachePath
                        headers:(NSDictionary *)headers
                       progress:(DownloadProgressBlock)progressBlock
                        success:(DownloadSuccessBlock)successBlock
                        failure:(DownloadFailureBlock)failureBlock {
    
    return [[self alloc] downloadFileWithURLString:URLString
                                         cachePath:cachePath
                                           headers:headers
                                          progress:progressBlock
                                           success:successBlock
                                           failure:failureBlock];
}

+ (void)pauseWithOperation:(id)operation {
    
    [[self alloc] pauseWithOperation:operation];
}

- (unsigned long long)fileSizeForPath:(NSString *)path {
    
    signed long long fileSize = 0;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path]) {
        
        NSError *error = nil;
        
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        
        if (!error && fileDict) {
            
            fileSize = [fileDict fileSize];
        }
    }
    
    return fileSize;
}

- (id)downloadFileWithURLString:(NSString *)URLString
                      cachePath:(NSString *)cachePath
                       progress:(DownloadProgressBlock)progressBlock
                        success:(DownloadSuccessBlock)successBlock
                        failure:(DownloadFailureBlock)failureBlock {
    
    return [self downloadFileWithURLString:URLString
                                 cachePath:cachePath
                                   headers:nil
                                  progress:progressBlock
                                   success:successBlock
                                   failure:failureBlock];
}

- (void)pauseWithOperation:(id)operation {
    
    [operation pause];
}


- (id)downloadFileWithURLString:(NSString *)URLString
                      cachePath:(NSString *)cachePath
                        headers:(NSDictionary *)headers
                       progress:(DownloadProgressBlock)progressBlock
                        success:(DownloadSuccessBlock)successBlock
                        failure:(DownloadFailureBlock)failureBlock {
    
    NSString * dirString =  [cachePath stringByDeletingLastPathComponent];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirString isDirectory:&isDir];
    
    if (!(isDir == YES && existed == YES)) {
        
        [fileManager createDirectoryAtPath:dirString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    unsigned long long downloadedBytes = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        
        //获取已下载的文件长度
        downloadedBytes = [self fileSizeForPath:cachePath];
        
        //检查文件是否已经下载了一部分
        if (downloadedBytes > 0) {
            
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    
    //设置header
    if (nil != headers) {
        for (id key in headers) {
            [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    // 不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    // 下载请求
    //idoperation = [[HTMIAFHTTPRequestOperation alloc] initWithRequest:request];
    //1.获取请求管理对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    __weak typeof (self) weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {

        // 下载进度
        CGFloat progress = ((CGFloat)downloadProgress.completedUnitCount + downloadedBytes) / ((CGFloat)downloadProgress.totalUnitCount + downloadedBytes);
        
        progressBlock(progress, ((CGFloat)downloadProgress.totalUnitCount + downloadedBytes) / 1024 / 1024.0f, ((CGFloat)downloadProgress.completedUnitCount + downloadedBytes) / 1024 / 1024.0f);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:cachePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            
            failureBlock(nil, error);
        }
        else {
            
            for (NSDictionary *dic in strongSelf.paths) {
                
                if ([cachePath isEqualToString:dic[@"path"]] && ![(id)dic[@"operation"] isPaused]) {
                    
                    [strongSelf.paths removeObject:dic];
                    break;
                }
            }
            
            successBlock(nil, response);
        }
    }];
    
    //开始下载
    [downloadTask resume];
    
    return downloadTask;
}

- (NSMutableDictionary *)sessionDictionary {
    if (!_sessionDictionary) {
        _sessionDictionary = [NSMutableDictionary dictionary];
    }
    return _sessionDictionary;
}

- (NSMutableArray *)paths {
    if (!_paths) {
        _paths = [[NSMutableArray alloc] init];
    }
    return _paths;
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
